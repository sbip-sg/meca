from typing import Self, List, Tuple
from web3 import Web3
import json

from config import Config
from models.user import User


class DiscoveryContract:
    _contract_instance = None

    def __init__(self, config: Config) -> None:
        self.config = config
        self.w3 = Web3(Web3.HTTPProvider(config.get_blockchain_provider_url()))
        with open(config.get_abi_path()) as abi_definition:
            self.abi = json.load(abi_definition)["abi"]
        self.contract = self.w3.eth.contract(
            address=config.get_contract_address(), abi=self.abi
        )

    def __new__(cls, config) -> Self:
        if cls._contract_instance is None:
            cls._contract_instance = super().__new__(cls)
        return cls._contract_instance

    def call_function(self, unbuilt_function, add_params):
        try:
            print("Calling function: " + unbuilt_function.function_identifier)
            caller = self.config.get_wallet_address()
            built_function = unbuilt_function.build_transaction(
                {
                    "from": caller,
                    "gasPrice": self.w3.to_wei("50", "gwei"),
                    **add_params,
                    "nonce": self.w3.eth.get_transaction_count(caller),
                    "chainId": self.w3.eth.chain_id,
                }
            )
            signed_tx = self.w3.eth.account.sign_transaction(
                built_function, self.config.get_wallet_private_key()
            )
            tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
            tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
            if tx_receipt["status"] != 1:
                raise Exception(
                    "Transaction failed. Check etherscan for "
                    + tx_receipt.transactionHash.hex()
                )
        except ValueError as e:
            raise Exception(e)

    # record user in the contract
    def set_user(self, did: str, po_did: str, timestamp: int, cpu: int, mem: int):
        unbuilt_function = self.contract.functions.setUser(did, po_did, timestamp, cpu, mem)
        self.call_function(unbuilt_function, {"gas": 750000})

    def update_timestamp(self, did: str, timestamp: int):
        unbuilt_function = self.contract.functions.updateTimestamp(did, timestamp)
        self.call_function(unbuilt_function, {"gas": 150000})

    # get user from the contract
    def get_user(self, did: str) -> User:
        user_tuple = self.contract.functions.getUser(did).call()
        return User(*user_tuple)

    # get available user's queue name from the contract
    def get_available_user(self, current_timestamp: int, cpu: int, mem: int) -> User:
        lazy_remove_expired_users = self.contract.functions.lazyRemoveExpiredUsers(
            current_timestamp
        )
        self.call_function(lazy_remove_expired_users, {"gas": 300000})
        user_tuple = self.contract.functions.getAvailableUser(cpu, mem).call()
        user = User(*user_tuple)
        if user.is_user:
            self.subtract_resource(user.did, cpu, mem)
            return user
        else:
            return None

    # get all dids and timestamps from the contract
    def get_all_did_to_timestamps(self) -> List[Tuple[str, int]]:
        try:
            (
                user_list,
                timestamp_list,
            ) = self.contract.functions.getAllDidToTimestamps().call()
            return [
                (did, timestamp) for (did, timestamp) in zip(user_list, timestamp_list)
            ]
        except ValueError as e:
            print(e)

    # remove user from the contract
    def remove_user(self, did: str) -> None:
        unbuilt_function = self.contract.functions.removeUser(did)
        self.call_function(unbuilt_function, {"gas": 300000})

    # remove users from the contract
    def remove_users(self, dids: List[str]) -> None:
        unbuilt_function = self.contract.functions.removeUsers(dids)
        self.call_function(unbuilt_function, {"gas": 300000})

    def add_resource(self, did: str, cpu: int, mem: int) -> None:
        unbuilt_function = self.contract.functions.addResource(did, cpu, mem)
        self.call_function(unbuilt_function, {"gas": 150000})

    def subtract_resource(self, did: str, cpu: int, mem: int) -> None:
        unbuilt_function = self.contract.functions.subtractResource(did, cpu, mem)
        self.call_function(unbuilt_function, {"gas": 150000})

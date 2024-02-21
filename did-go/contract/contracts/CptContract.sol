pragma solidity >=0.4.22 <0.9.0;

contract CptContract {
    address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    uint public constant AUTHORITY_ISSUER_START_ID = 1000;
    uint public constant NONE_AUTHORITY_ISSUER_START_ID = 2000000;
    uint private authority_issuer_current_id = 1000;
    uint private none_authority_issuer_current_id = 2000000;

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Cpt {
        //store the weid address of cpt publisher
        address publisher;
        // [0]: cpt version, [1]: created, [2]: updated, [3]: the CPT ID
        int[8] intArray;
        // [0]: desc
        bytes32[8] bytes32Array;
        //store json schema
        bytes32[32] jsonSchemaArray;
        //store signature
        Signature signature;
    }

    mapping(uint => Cpt) private cptMap;
    uint[] private cptIdList;

    // Error codes
    uint private constant CPT_NOT_EXIST = 500301;
    uint private constant AUTHORITY_ISSUER_CPT_ID_EXCEED_MAX = 500302;
    uint private constant CPT_PUBLISHER_NOT_EXIST = 500303;
    uint private constant CPT_ALREADY_EXIST = 500304;
    uint private constant NO_PERMISSION = 500305;

    // Default CPT version
    int private constant CPT_DEFAULT_VERSION = 1;

    address private cptDataStorageAddress;

    event RegisterCptRetLog(uint retCode, uint cptId, int cptVersion);

    event UpdateCptRetLog(uint retCode, uint cptId, int cptVersion);

    function isCptExist(uint cptId) public view returns (bool) {
        // int[8] memory intArray = getCptIntArray(cptId);
        // if (intArray[0] != 0) {
        //     return true;
        // } else {
        //     return false;
        // }
        return cptMap[cptId].publisher != ZERO_ADDRESS;
    }

    function allocateCptId() public returns (uint cptId) {
        while (isCptExist(none_authority_issuer_current_id)) {
            none_authority_issuer_current_id++;
        }
        cptId = none_authority_issuer_current_id++;
    }

    function getCptIdFromIndex(uint index) public view returns (uint) {
        return cptIdList[index];
    }

    function getDatasetLength() public view returns (uint) {
        return cptIdList.length;
    }

    function getCptIdList(
        uint startPos,
        uint num
    ) public view returns (uint[] memory) {
        uint totalLength = getDatasetLength();
        uint dataLength;
        if (totalLength < startPos) {
            return new uint[](1);
        } else if (totalLength <= startPos + num) {
            dataLength = totalLength - startPos;
        } else {
            dataLength = num;
        }
        uint[] memory result = new uint[](dataLength);
        for (uint i = 0; i < dataLength; i++) {
            result[i] = getCptIdFromIndex(startPos + i);
        }
        return result;
    }

    function getTotalCptId() public view returns (uint) {
        return getDatasetLength();
    }

    function putCpt(
        uint cptId,
        address cptPublisher,
        int[8] memory cptIntArray,
        bytes32[8] memory cptBytes32Array,
        bytes32[32] memory cptJsonSchemaArray,
        uint8 cptV,
        bytes32 cptR,
        bytes32 cptS
    ) public returns (bool) {
        Signature memory cptSignature = Signature({v: cptV, r: cptR, s: cptS});
        cptMap[cptId] = Cpt({
            publisher: cptPublisher,
            intArray: cptIntArray,
            bytes32Array: cptBytes32Array,
            jsonSchemaArray: cptJsonSchemaArray,
            signature: cptSignature
        });
        cptIdList.push(cptId);
        return true;
    }

    function registerCptInner(
        address publisher,
        int[8] memory intArray,
        bytes32[8] memory bytes32Array,
        bytes32[32] memory jsonSchemaArray,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address dataStorageAddress
    ) private returns (bool) {
        uint cptId = allocateCptId();

        int cptVersion = CPT_DEFAULT_VERSION;
        intArray[0] = cptVersion;
        putCpt(
            cptId,
            publisher,
            intArray,
            bytes32Array,
            jsonSchemaArray,
            v,
            r,
            s
        );

        emit RegisterCptRetLog(0, cptId, cptVersion);
        return true;
    }

    function registerCpt(
        address publisher,
        int[8] memory intArray,
        bytes32[8] memory bytes32Array,
        bytes32[32] memory jsonSchemaArray,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bool) {
        return
            registerCptInner(
                publisher,
                intArray,
                bytes32Array,
                jsonSchemaArray,
                v,
                r,
                s,
                cptDataStorageAddress
            );
    }

    function getCptPublisher(
        uint cptId
    ) public view returns (address publisher) {
        Cpt memory cpt = cptMap[cptId];
        publisher = cpt.publisher;
    }

    function getCptIntArray(
        uint cptId
    ) public view returns (int[8] memory intArray) {
        Cpt memory cpt = cptMap[cptId];
        intArray = cpt.intArray;
    }

    function getCptDynamicIntArray(
        uint cptId,
        address dataStorageAddress
    ) public view returns (int[] memory) {
        int[8] memory staticIntArray = getCptIntArray(cptId);
        int[] memory dynamicIntArray = new int[](8);
        for (uint i = 0; i < 8; i++) {
            dynamicIntArray[i] = staticIntArray[i];
        }
        return dynamicIntArray;
    }

    function getCptDynamicBytes32Array(
        uint cptId,
        address dataStorageAddress
    ) public view returns (bytes32[] memory) {
        Cpt memory cpt = cptMap[cptId];
        bytes32[8] memory staticBytes32Array = cpt.bytes32Array;
        bytes32[] memory dynamicBytes32Array = new bytes32[](8);
        for (uint i = 0; i < 8; i++) {
            dynamicBytes32Array[i] = staticBytes32Array[i];
        }
        return dynamicBytes32Array;
    }

    function getCptDynamicJsonSchemaArray(
        uint cptId,
        address dataStorageAddress
    ) public view returns (bytes32[] memory) {
        Cpt memory cpt = cptMap[cptId];
        bytes32[32] memory staticBytes32Array = cpt.jsonSchemaArray;
        bytes32[] memory dynamicBytes32Array = new bytes32[](32);
        for (uint i = 0; i < 32; i++) {
            dynamicBytes32Array[i] = staticBytes32Array[i];
        }
        return dynamicBytes32Array;
    }

    function getCptSignature(
        uint cptId
    ) public view returns (uint8 v, bytes32 r, bytes32 s) {
        Cpt memory cpt = cptMap[cptId];
        v = cpt.signature.v;
        r = cpt.signature.r;
        s = cpt.signature.s;
    }

    function queryCptInner(
        uint cptId,
        address dataStorageAddress
    )
        private
        view
        returns (
            address publisher,
            int[] memory intArray,
            bytes32[] memory bytes32Array,
            bytes32[] memory jsonSchemaArray,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        publisher = getCptPublisher(cptId);
        intArray = getCptDynamicIntArray(cptId, dataStorageAddress);
        bytes32Array = getCptDynamicBytes32Array(cptId, dataStorageAddress);
        jsonSchemaArray = getCptDynamicJsonSchemaArray(
            cptId,
            dataStorageAddress
        );
        (v, r, s) = getCptSignature(cptId);
    }

    function queryCpt(
        uint cptId
    )
        public
        view
        returns (
            address publisher,
            int[] memory intArray,
            bytes32[] memory bytes32Array,
            bytes32[] memory jsonSchemaArray,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        return queryCptInner(cptId, cptDataStorageAddress);
    }

    function updateCptInner(
        uint cptId,
        address publisher,
        int[8] memory intArray,
        bytes32[8] memory bytes32Array,
        bytes32[32] memory jsonSchemaArray,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address dataStorageAddress
    ) private returns (bool) {
        if (isCptExist(cptId)) {
            int[8] memory cptIntArray = getCptIntArray(cptId);
            int cptVersion = cptIntArray[0] + 1;
            intArray[0] = cptVersion;
            int created = cptIntArray[1];
            intArray[1] = created;
            putCpt(
                cptId,
                publisher,
                intArray,
                bytes32Array,
                jsonSchemaArray,
                v,
                r,
                s
            );
            emit UpdateCptRetLog(0, cptId, cptVersion);
            return true;
        } else {
            emit UpdateCptRetLog(CPT_NOT_EXIST, 0, 0);
            return false;
        }
    }

    function updateCpt(
        uint cptId,
        address publisher,
        int[8] memory intArray,
        bytes32[8] memory bytes32Array,
        bytes32[32] memory jsonSchemaArray,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bool) {
        return
            updateCptInner(
                cptId,
                publisher,
                intArray,
                bytes32Array,
                jsonSchemaArray,
                v,
                r,
                s,
                cptDataStorageAddress
            );
    }
}

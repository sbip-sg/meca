package com.meca.did.protocol.base;

import com.meca.did.constant.CredentialType;
import com.meca.did.constant.ErrorCode;
import com.meca.did.constant.ParamKeyConstant;
import com.meca.did.exception.DataTypeCastException;
import com.meca.did.protocol.inf.Hashable;
import com.meca.did.protocol.inf.IProof;
import com.meca.did.protocol.inf.JsonSerializer;
import com.meca.did.util.CredentialPojoUtils;
import com.meca.did.util.DataToolUtils;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
public class CredentialPojo implements IProof, JsonSerializer, Hashable {

    private static final Logger logger = LoggerFactory.getLogger(CredentialPojo.class);

    /**
     * the serialVersionUID.
     */
    private static final long serialVersionUID = 8197843857223846978L;

    /**
     * Required: The context field.
     */
    @ApiModelProperty(example = "https://www.w3.org/2018/credentials/v1")
    private String context;

    /**
     * Required: The ID.
     */
    @ApiModelProperty(example = "ae559160-c1bb-4f15-845e-af7d7912e07b")
    private String id;

    /**
     * Required: The CPT type in standard integer format.
     */
    @ApiModelProperty(example = "1")
    private Integer cptId;

    /**
     * Required: The issuer DID.
     */
    @ApiModelProperty(example = "did:meca:0xfd340b5a30de452ae4a14dd1b92a7006868a29c8")
    private String issuer;

    /**
     * Required: The create date.
     */
    @ApiModelProperty(example = "1644379660")
    private Long issuanceDate;

    /**
     * Required: The expire date.
     */
    @ApiModelProperty(example = "4797979660")
    private Long expirationDate;

    /**
     * Required: The claim data.
     */
    @ApiModelProperty(example = "{\n"
        + "      \"gender\": \"M\",\n"
        + "      \"name\": \"Chai\",\n"
        + "      \"DID\": \"did:meca:0x0fa21fd3d11d2cd5e6cdef2c7cd6531a25a5964f\"\n"
        + "    }")
    private Map<String, Object> claim;

    /**
     * Required: The credential proof data.
     */
    @ApiModelProperty(example = "{\n"
        + "      \"creator\": \"did:meca:0xfd340b5a30de452ae4a14dd1b92a7006868a29c8\",\n"
        + "      \"signature\": \"G1r9auOBUNK6qa/vnWsSdpBg5UW4bXc2nAnbRTRI/kxFHv8w4S5VYUx6cyQ3YxEnErbWMhsvOfA83kiQ/bH5A8A=\",\n"
        + "      \"created\": \"1578467662\",\n"
        + "      \"type\": \"Secp256k1\"\n"
        + "    }")
    private Proof proof;

    /**
     * Required: The credential type default is VerifiableCredential.
     */
    @ApiModelProperty(example = "[\"VerifiableCredential\"]")
    private List<String> type;

    /**
     * create CredentialPojo with JSON String.
     *
     * @param credentialJson the CredentialPojo JSON String
     * @return CredentialPojo
     */
    public static CredentialPojo fromJson(String credentialJson) throws DataTypeCastException {
        if (StringUtils.isBlank(credentialJson)) {
            logger.error("create credential with JSON String failed, "
                    + "the credential JSON String is null");
            throw new DataTypeCastException("the credential JSON String is null");
        }

        String credentialString = credentialJson;
        if (DataToolUtils.isValidFromToJson(credentialJson)) {
            credentialString = DataToolUtils.removeTagFromToJson(credentialJson);
        }
        Map<String, Object> credentialMap = (HashMap<String, Object>) DataToolUtils
                .deserialize(credentialString, HashMap.class);

        Object type = credentialMap.get(ParamKeyConstant.PROOF_TYPE);

        CredentialPojo credentialPojo = DataToolUtils.deserialize(
                DataToolUtils.convertUtcToTimestamp(credentialString),
                CredentialPojo.class
        );
        ErrorCode checkResp = CredentialPojoUtils.isCredentialPojoValid(credentialPojo);
        if (ErrorCode.SUCCESS.getCode() != checkResp.getCode()) {
            logger.error("create CredentialPojo with JSON String failed, {}",
                    checkResp.getCodeDesc());
            throw new DataTypeCastException(checkResp.getCodeDesc());
        }
        if (!CredentialPojoUtils.validClaimAndSaltForMap(
                credentialPojo.getClaim(),
                credentialPojo.getSalt())) {
            logger.error("create PresentationE with JSON String failed, claim and salt of "
                    + "credentialPojo not match.");
            throw new DataTypeCastException("claim and salt of credentialPojo not match.");
        }
        return credentialPojo;
    }

    /**
     * 添加type.
     *
     * @param typeValue the typeValue
     */
    public void addType(String typeValue) {
        if (type == null) {
            type = new ArrayList<String>();
        }
        type.add(typeValue);
    }

    /**
     * Directly extract the signature value from credential.
     *
     * @return signature value
     */
    public String getSignature() {
        return proof.getSignatureValue();
    }

    /**
     * Directly extract the proof type from credential.
     *
     * @return proof type
     */
    public String getProofType() {
        return proof.getType();
    }

    /**
     * Directly extract the salt from credential.
     *
     * @return salt
     */
    public Map<String, Object> getSalt() {
        return proof.getSalt();
    }

    /**
     * put the salt into proof.
     *
     * @param salt map of salt
     */
    public void setSalt(Map<String, Object> salt) {
        proof.setSalt(salt);
    }

    /**
     * convert CredentialPojo to JSON String.
     *
     * @return CredentialPojo
     */
    @Override
    public String toJson() throws DataTypeCastException {
        String json = DataToolUtils.convertTimestampToUtc(DataToolUtils.serialize(this));
        return DataToolUtils.addTagFromToJson(json);
    }

    /**
     * Generate the unique hash of this CredentialPojo.
     *
     * @return hash value
     */
    public String getHash() {
        if (CredentialPojoUtils.isCredentialPojoValid(this) != ErrorCode.SUCCESS) {
            return StringUtils.EMPTY;
        }
        return CredentialPojoUtils.getCredentialPojoHash(this, null);
    }

    /**
     * Get the signature thumbprint for re-signing.
     *
     * @return thumbprint
     */
    public String getSignatureThumbprint() {
        return CredentialPojoUtils.getCredentialThumbprintWithoutSig(this, this.getSalt(), null);
    }

    /**
     * Get the CredentialType.
     *
     * @return the CredentialType
     */
    public CredentialType getCredentialType() {
        if (this.type == null) {
            logger.warn("[getCredentialType] the type is null.");
            return null;
        }
        if (this.type.contains(CredentialType.ORIGINAL.getName())) {
            return CredentialType.ORIGINAL;
        } else {
            logger.warn("[getCredentialType] the type does not contain default CredentialType.");
            return null;
        }
    }
}

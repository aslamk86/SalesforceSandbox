//Generated by wsdl2apex

public class dto19ApiEchosign {
    public class SignerFormField {
        public String alignment;
        public String anyOrAll;
        public String backgroundColor;
        public String borderColor;
        public String borderStyle;
        public Double borderWidth;
        public String calculatedExpression;
        public dto19ApiEchosign.ArrayOfSignerFormFieldCondition conditions;
        public String contentType;
        public String defaultValue;
        public String displayFormat;
        public String displayFormatType;
        public String displayLabel;
        public String fontColor;
        public String fontName;
        public Double fontSize;
        public Boolean hidden;
        public apiEchosign.ArrayOfString hiddenOptions;
        public String inputType;
        public dto19ApiEchosign.ArrayOfSignerFormFieldLocation locations;
        public Boolean masked;
        public Integer maxLength;
        public Double maxNumberValue;
        public Integer minLength;
        public Double minNumberValue;
        public String name;
        public String radioCheckType;
        public Boolean readOnly;
        public String regularExpression;
        public Boolean required;
        public String showOrHide;
        public String specialErrMsg;
        public String specialFormula;
        public String tooltip;
        public String validationRule;
        public apiEchosign.ArrayOfString visibleOptions;
        private String[] alignment_type_info = new String[]{'alignment','http://dto19.api.echosign',null,'0','1','true'};
        private String[] anyOrAll_type_info = new String[]{'anyOrAll','http://dto19.api.echosign',null,'0','1','true'};
        private String[] backgroundColor_type_info = new String[]{'backgroundColor','http://dto19.api.echosign',null,'0','1','true'};
        private String[] borderColor_type_info = new String[]{'borderColor','http://dto19.api.echosign',null,'0','1','true'};
        private String[] borderStyle_type_info = new String[]{'borderStyle','http://dto19.api.echosign',null,'0','1','true'};
        private String[] borderWidth_type_info = new String[]{'borderWidth','http://dto19.api.echosign',null,'0','1','false'};
        private String[] calculatedExpression_type_info = new String[]{'calculatedExpression','http://dto19.api.echosign',null,'0','1','true'};
        private String[] conditions_type_info = new String[]{'conditions','http://dto19.api.echosign',null,'0','1','true'};
        private String[] contentType_type_info = new String[]{'contentType','http://dto19.api.echosign',null,'0','1','true'};
        private String[] defaultValue_type_info = new String[]{'defaultValue','http://dto19.api.echosign',null,'0','1','true'};
        private String[] displayFormat_type_info = new String[]{'displayFormat','http://dto19.api.echosign',null,'0','1','true'};
        private String[] displayFormatType_type_info = new String[]{'displayFormatType','http://dto19.api.echosign',null,'0','1','true'};
        private String[] displayLabel_type_info = new String[]{'displayLabel','http://dto19.api.echosign',null,'0','1','true'};
        private String[] fontColor_type_info = new String[]{'fontColor','http://dto19.api.echosign',null,'0','1','true'};
        private String[] fontName_type_info = new String[]{'fontName','http://dto19.api.echosign',null,'0','1','true'};
        private String[] fontSize_type_info = new String[]{'fontSize','http://dto19.api.echosign',null,'0','1','false'};
        private String[] hidden_type_info = new String[]{'hidden','http://dto19.api.echosign',null,'0','1','false'};
        private String[] hiddenOptions_type_info = new String[]{'hiddenOptions','http://dto19.api.echosign',null,'0','1','true'};
        private String[] inputType_type_info = new String[]{'inputType','http://dto19.api.echosign',null,'0','1','true'};
        private String[] locations_type_info = new String[]{'locations','http://dto19.api.echosign',null,'0','1','true'};
        private String[] masked_type_info = new String[]{'masked','http://dto19.api.echosign',null,'0','1','false'};
        private String[] maxLength_type_info = new String[]{'maxLength','http://dto19.api.echosign',null,'0','1','false'};
        private String[] maxNumberValue_type_info = new String[]{'maxNumberValue','http://dto19.api.echosign',null,'0','1','false'};
        private String[] minLength_type_info = new String[]{'minLength','http://dto19.api.echosign',null,'0','1','false'};
        private String[] minNumberValue_type_info = new String[]{'minNumberValue','http://dto19.api.echosign',null,'0','1','false'};
        private String[] name_type_info = new String[]{'name','http://dto19.api.echosign',null,'0','1','true'};
        private String[] radioCheckType_type_info = new String[]{'radioCheckType','http://dto19.api.echosign',null,'0','1','true'};
        private String[] readOnly_type_info = new String[]{'readOnly','http://dto19.api.echosign',null,'0','1','false'};
        private String[] regularExpression_type_info = new String[]{'regularExpression','http://dto19.api.echosign',null,'0','1','true'};
        private String[] required_type_info = new String[]{'required','http://dto19.api.echosign',null,'0','1','false'};
        private String[] showOrHide_type_info = new String[]{'showOrHide','http://dto19.api.echosign',null,'0','1','true'};
        private String[] specialErrMsg_type_info = new String[]{'specialErrMsg','http://dto19.api.echosign',null,'0','1','true'};
        private String[] specialFormula_type_info = new String[]{'specialFormula','http://dto19.api.echosign',null,'0','1','true'};
        private String[] tooltip_type_info = new String[]{'tooltip','http://dto19.api.echosign',null,'0','1','true'};
        private String[] validationRule_type_info = new String[]{'validationRule','http://dto19.api.echosign',null,'0','1','true'};
        private String[] visibleOptions_type_info = new String[]{'visibleOptions','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'alignment','anyOrAll','backgroundColor','borderColor','borderStyle','borderWidth','calculatedExpression','conditions','contentType','defaultValue','displayFormat','displayFormatType','displayLabel','fontColor','fontName','fontSize','hidden','hiddenOptions','inputType','locations','masked','maxLength','maxNumberValue','minLength','minNumberValue','name','radioCheckType','readOnly','regularExpression','required','showOrHide','specialErrMsg','specialFormula','tooltip','validationRule','visibleOptions'};
    }
    public class ArrayOfSignerFormFieldLocation {
        public dto19ApiEchosign.SignerFormFieldLocation[] SignerFormFieldLocation;
        private String[] SignerFormFieldLocation_type_info = new String[]{'SignerFormFieldLocation','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'SignerFormFieldLocation'};
    }
    public class GetSignerFormFieldsOptions {
        public String signerEmail;
        private String[] signerEmail_type_info = new String[]{'signerEmail','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'signerEmail'};
    }
    public class ArrayOfDocumentPageInfo {
        public dto19ApiEchosign.DocumentPageInfo[] DocumentPageInfo;
        private String[] DocumentPageInfo_type_info = new String[]{'DocumentPageInfo','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'DocumentPageInfo'};
    }
    public class PhoneInfo {
        public String countryCode;
        public String phone;
        private String[] countryCode_type_info = new String[]{'countryCode','http://dto19.api.echosign',null,'0','1','true'};
        private String[] phone_type_info = new String[]{'phone','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','phone'};
    }
    public class ArrayOfSignerFormField {
        public dto19ApiEchosign.SignerFormField[] SignerFormField;
        private String[] SignerFormField_type_info = new String[]{'SignerFormField','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'SignerFormField'};
    }
    public class ArrayOfPhoneInfo {
        public dto19ApiEchosign.PhoneInfo[] PhoneInfo;
        private String[] PhoneInfo_type_info = new String[]{'PhoneInfo','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'PhoneInfo'};
    }
    public class OnBehalfOfUser {
        public String email;
        public String userKey;
        private String[] email_type_info = new String[]{'email','http://dto19.api.echosign',null,'0','1','true'};
        private String[] userKey_type_info = new String[]{'userKey','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'email','userKey'};
    }
    public class ArrayOfDocumentInfo {
        public dto19ApiEchosign.DocumentInfo[] DocumentInfo;
        private String[] DocumentInfo_type_info = new String[]{'DocumentInfo','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'DocumentInfo'};
    }
    public class FormValue {
        public String fieldInputType;
        public String fieldName;
        public String fieldValue;
        private String[] fieldInputType_type_info = new String[]{'fieldInputType','http://dto19.api.echosign',null,'0','1','true'};
        private String[] fieldName_type_info = new String[]{'fieldName','http://dto19.api.echosign',null,'0','1','true'};
        private String[] fieldValue_type_info = new String[]{'fieldValue','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'fieldInputType','fieldName','fieldValue'};
    }
    public class GetSignerFormFieldsResult {
        public String errorCode;
        public String errorMessage;
        public dto19ApiEchosign.ArrayOfFormValue formValuesForConditionalsAndCalculations;
        public String locale;
        public apiEchosign.ArrayOfString orderedCalculatedFieldNames;
        public apiEchosign.ArrayOfString orderedConditionalFieldNames;
        public String signer;
        public dto19ApiEchosign.ArrayOfSignerFormField signerFormFields;
        public Boolean success;
        private String[] errorCode_type_info = new String[]{'errorCode','http://dto19.api.echosign',null,'0','1','true'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://dto19.api.echosign',null,'0','1','true'};
        private String[] formValuesForConditionalsAndCalculations_type_info = new String[]{'formValuesForConditionalsAndCalculations','http://dto19.api.echosign',null,'0','1','true'};
        private String[] locale_type_info = new String[]{'locale','http://dto19.api.echosign',null,'0','1','true'};
        private String[] orderedCalculatedFieldNames_type_info = new String[]{'orderedCalculatedFieldNames','http://dto19.api.echosign',null,'0','1','true'};
        private String[] orderedConditionalFieldNames_type_info = new String[]{'orderedConditionalFieldNames','http://dto19.api.echosign',null,'0','1','true'};
        private String[] signer_type_info = new String[]{'signer','http://dto19.api.echosign',null,'0','1','true'};
        private String[] signerFormFields_type_info = new String[]{'signerFormFields','http://dto19.api.echosign',null,'0','1','true'};
        private String[] success_type_info = new String[]{'success','http://dto19.api.echosign',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage','formValuesForConditionalsAndCalculations','locale','orderedCalculatedFieldNames','orderedConditionalFieldNames','signer','signerFormFields','success'};
    }
    public class GetDocumentPagesInfoResult {
        public dto19ApiEchosign.ArrayOfDocumentPageInfo documentPagesInfo;
        public String errorCode;
        public String errorMessage;
        public Boolean success;
        private String[] documentPagesInfo_type_info = new String[]{'documentPagesInfo','http://dto19.api.echosign',null,'0','1','true'};
        private String[] errorCode_type_info = new String[]{'errorCode','http://dto19.api.echosign',null,'0','1','true'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://dto19.api.echosign',null,'0','1','true'};
        private String[] success_type_info = new String[]{'success','http://dto19.api.echosign',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'documentPagesInfo','errorCode','errorMessage','success'};
    }
    public class ParticipantInfo {
        public dto19ApiEchosign.ArrayOfParticipantInfo alternateParticipants;
        public dto19ApiEchosign.ArrayOfParticipantRole roles;
        public dto19ApiEchosign.ArrayOfParticipantSecurityOption securityOptions;
        public String status;
        public String company;
        public String email;
        public String name;
        public String title;
        private String[] alternateParticipants_type_info = new String[]{'alternateParticipants','http://dto19.api.echosign',null,'0','1','true'};
        private String[] roles_type_info = new String[]{'roles','http://dto19.api.echosign',null,'0','1','true'};
        private String[] securityOptions_type_info = new String[]{'securityOptions','http://dto19.api.echosign',null,'0','1','true'};
        private String[] status_type_info = new String[]{'status','http://dto19.api.echosign',null,'0','1','true'};
        private String[] company_type_info = new String[]{'company','http://dto19.api.echosign',null,'0','1','true'};
        private String[] email_type_info = new String[]{'email','http://dto19.api.echosign',null,'0','1','true'};
        private String[] name_type_info = new String[]{'name','http://dto19.api.echosign',null,'0','1','true'};
        private String[] title_type_info = new String[]{'title','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'alternateParticipants','roles','securityOptions','status','company','email','name','title'};
    }
    public class ArrayOfParticipantSecurityOption {
        public String[] ParticipantSecurityOption;
        private String[] ParticipantSecurityOption_type_info = new String[]{'ParticipantSecurityOption','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'ParticipantSecurityOption'};
    }
    public class DocumentInfoList {
        public dto19ApiEchosign.ArrayOfDocumentInfo documentInfos;
        public String errorCode;
        public String errorMessage;
        public Boolean success;
        private String[] documentInfos_type_info = new String[]{'documentInfos','http://dto19.api.echosign',null,'0','1','true'};
        private String[] errorCode_type_info = new String[]{'errorCode','http://dto19.api.echosign',null,'0','1','true'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://dto19.api.echosign',null,'0','1','true'};
        private String[] success_type_info = new String[]{'success','http://dto19.api.echosign',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'documentInfos','errorCode','errorMessage','success'};
    }
    public class SignerFormFieldLocation {
        public Double height;
        public Double left;
        public Integer pageNumber;
        public Double top;
        public Double width;
        private String[] height_type_info = new String[]{'height','http://dto19.api.echosign',null,'0','1','false'};
        private String[] left_type_info = new String[]{'left','http://dto19.api.echosign',null,'0','1','false'};
        private String[] pageNumber_type_info = new String[]{'pageNumber','http://dto19.api.echosign',null,'0','1','false'};
        private String[] top_type_info = new String[]{'top','http://dto19.api.echosign',null,'0','1','false'};
        private String[] width_type_info = new String[]{'width','http://dto19.api.echosign',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'height','left','pageNumber','top','width'};
    }
    public class DocumentPageInfo {
        public Double height;
        public Integer pageNumber;
        public Integer rotation;
        public Double width;
        private String[] height_type_info = new String[]{'height','http://dto19.api.echosign',null,'0','1','false'};
        private String[] pageNumber_type_info = new String[]{'pageNumber','http://dto19.api.echosign',null,'0','1','false'};
        private String[] rotation_type_info = new String[]{'rotation','http://dto19.api.echosign',null,'0','1','false'};
        private String[] width_type_info = new String[]{'width','http://dto19.api.echosign',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'height','pageNumber','rotation','width'};
    }
    public class EmbeddedViewOptions {
        public String embeddedViewObject;
        public String embeddedViewTarget;
        public Boolean noChrome;
        private String[] embeddedViewObject_type_info = new String[]{'embeddedViewObject','http://dto19.api.echosign',null,'0','1','true'};
        private String[] embeddedViewTarget_type_info = new String[]{'embeddedViewTarget','http://dto19.api.echosign',null,'0','1','true'};
        private String[] noChrome_type_info = new String[]{'noChrome','http://dto19.api.echosign',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'embeddedViewObject','embeddedViewTarget','noChrome'};
    }
    public class SignerFormFieldCondition {
        public String fieldName;
        public String operator;
        public String value;
        public Integer whenFieldLocationIndex;
        public String whenFieldName;
        private String[] fieldName_type_info = new String[]{'fieldName','http://dto19.api.echosign',null,'0','1','true'};
        private String[] operator_type_info = new String[]{'operator','http://dto19.api.echosign',null,'0','1','true'};
        private String[] value_type_info = new String[]{'value','http://dto19.api.echosign',null,'0','1','true'};
        private String[] whenFieldLocationIndex_type_info = new String[]{'whenFieldLocationIndex','http://dto19.api.echosign',null,'0','1','false'};
        private String[] whenFieldName_type_info = new String[]{'whenFieldName','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'fieldName','operator','value','whenFieldLocationIndex','whenFieldName'};
    }
    public class GetEmbeddedViewResult {
        public String errorCode;
        public String errorMessage;
        public Boolean success;
        public String url;
        private String[] errorCode_type_info = new String[]{'errorCode','http://dto19.api.echosign',null,'0','1','true'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://dto19.api.echosign',null,'0','1','true'};
        private String[] success_type_info = new String[]{'success','http://dto19.api.echosign',null,'0','1','false'};
        private String[] url_type_info = new String[]{'url','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage','success','url'};
    }
    public class ArrayOfSignerFormFieldCondition {
        public dto19ApiEchosign.SignerFormFieldCondition[] SignerFormFieldCondition;
        private String[] SignerFormFieldCondition_type_info = new String[]{'SignerFormFieldCondition','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'SignerFormFieldCondition'};
    }
    public class DocumentInfo {
        public dto19ApiEchosign.ArrayOfParticipantInfo participants;
        public dto18ApiEchosign.ArrayOfDocumentHistoryEvent events;
        public String status;
        public String documentKey;
        public String latestDocumentKey;
        public DateTime expiration;
        public String locale;
        public String message;
        public String name;
        public dto9ApiEchosign.ArrayOfNextParticipantInfo nextParticipantInfos;
        public dto13ApiEchosign.ArrayOfSecurityOption securityOptions;
        private String[] participants_type_info = new String[]{'participants','http://dto19.api.echosign',null,'0','1','true'};
        private String[] events_type_info = new String[]{'events','http://dto19.api.echosign',null,'0','1','true'};
        private String[] status_type_info = new String[]{'status','http://dto19.api.echosign',null,'0','1','true'};
        private String[] documentKey_type_info = new String[]{'documentKey','http://dto19.api.echosign',null,'0','1','true'};
        private String[] latestDocumentKey_type_info = new String[]{'latestDocumentKey','http://dto19.api.echosign',null,'0','1','true'};
        private String[] expiration_type_info = new String[]{'expiration','http://dto19.api.echosign',null,'0','1','false'};
        private String[] locale_type_info = new String[]{'locale','http://dto19.api.echosign',null,'0','1','true'};
        private String[] message_type_info = new String[]{'message','http://dto19.api.echosign',null,'0','1','true'};
        private String[] name_type_info = new String[]{'name','http://dto19.api.echosign',null,'0','1','true'};
        private String[] nextParticipantInfos_type_info = new String[]{'nextParticipantInfos','http://dto19.api.echosign',null,'0','1','true'};
        private String[] securityOptions_type_info = new String[]{'securityOptions','http://dto19.api.echosign',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'participants','events','status','documentKey','latestDocumentKey','expiration','locale','message','name','nextParticipantInfos','securityOptions'};
    }
    public class ArrayOfParticipantRole {
        public String[] ParticipantRole;
        private String[] ParticipantRole_type_info = new String[]{'ParticipantRole','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'ParticipantRole'};
    }
    public class ArrayOfParticipantInfo {
        public dto19ApiEchosign.ParticipantInfo[] ParticipantInfo;
        private String[] ParticipantInfo_type_info = new String[]{'ParticipantInfo','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'ParticipantInfo'};
    }
    public class ArrayOfFormValue {
        public dto19ApiEchosign.FormValue[] FormValue;
        private String[] FormValue_type_info = new String[]{'FormValue','http://dto19.api.echosign',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://dto19.api.echosign','true','true'};
        private String[] field_order_type_info = new String[]{'FormValue'};
    }
}
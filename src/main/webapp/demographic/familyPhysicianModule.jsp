<%@page import="oscar.*" %>
<%@page import="java.util.*" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Demographic" %>
<%@page import="org.oscarehr.common.dao.DemographicDao" %>
<%@page import="org.oscarehr.common.model.ProfessionalSpecialist" %>
<%@page import="org.oscarehr.common.dao.ProfessionalSpecialistDao" %>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<% 
OscarProperties oscarProps = OscarProperties.getInstance();
ProfessionalSpecialistDao professionalSpecialistDao = (ProfessionalSpecialistDao) SpringUtils.getBean("professionalSpecialistDao");
DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);

java.util.Properties oscarVariables = OscarProperties.getInstance();
String demographic_no = request.getParameter("demographic_no");
Demographic demographic = demographicDao.getDemographic(demographic_no);
String prov= (oscarVariables.getProperty("billregion","")).trim().toUpperCase();
boolean keyExists = demographicExtDao.getValueForDemoKey(Integer.parseInt(demographic_no), "familyPhysicianId")!=null?true:false;

int nStrShowLen = 20;

String family_doc = request.getParameter("family_doc");

String familyPhysicianId = keyExists?demographicExtDao.getValueForDemoKey(Integer.parseInt(demographic_no), "familyPhysicianId"):"";
String fam_doc_contents="";
String fam_doc_ohip="";
String fam_doc_name="";

fam_doc_contents = demographic.getFamilyPhysician();

if(fam_doc_contents!=null) {
    fam_doc_name = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyPhysician()), "fd");
    fam_doc_name = fam_doc_name != null ? fam_doc_name : "";
    fam_doc_ohip = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyPhysician()), "fdohip");
    fam_doc_ohip = fam_doc_ohip != null ? fam_doc_ohip : "";

    // work around for familyPhysicianId not previously stored in the demographicExt table
    if(familyPhysicianId == "" && fam_doc_ohip!=""){
        ProfessionalSpecialist professionalSpecialist = professionalSpecialistDao.getByReferralNo(fam_doc_ohip)!=null?professionalSpecialistDao.getByReferralNo(fam_doc_ohip):null;
        //make sure searching by ohip does not return a null result
        familyPhysicianId = professionalSpecialist!=null?String.valueOf(professionalSpecialist.getId()):"";
    }

    if(familyPhysicianId == "" && fam_doc_name.contains(",")){
        List<ProfessionalSpecialist> professionalSpecialists = professionalSpecialistDao.findByFullName(String.valueOf(fam_doc_name.split(",",0)),String.valueOf(fam_doc_name.split(",",1)));
        if(professionalSpecialists != null && professionalSpecialists.size() == 1){
            //get Id only if there is one match
            familyPhysicianId = String.valueOf(professionalSpecialists.get(0).getId());
        }
    }
    if (!keyExists){
        demographicExtDao.addKey((String) session.getAttribute("user"), demographic.getDemographicNo(), "familyPhysicianId", familyPhysicianId, "");
    }
}

%>

<%!
public String getDisabled(String fieldName) {
	String val = OscarProperties.getInstance().getProperty("demographic.edit."+fieldName,"");
	if(val != null && val.equals("disabled")) {
		return " disabled=\"disabled\" ";
	}

	return "";
}
%>

<script type="text/javascript" src="<%=request.getContextPath() %>/demographic/demographiceditdemographic.js"></script>

<!-- Family Doctor Field -->
<tr valign="top">
	<input type="hidden" name="f_doctor_id" size="17" maxlength="40" value="<%=familyPhysicianId%>">
    <td align="right" nowrap><b><bean:message
            key="demographic.demographiceditdemographic.formFamDoc" />: </b></td>
    <td align="left">
        <% if(oscarProps.getProperty("isMRefDocSelectList", "").equals("true") ) {
            // drop down list
            Properties prop = null;
            List<Properties> vecRef = new ArrayList<Properties>();
            List<ProfessionalSpecialist> specialists = professionalSpecialistDao.findAll();
            for(ProfessionalSpecialist specialist : specialists) {
                prop = new Properties();
                prop.setProperty("referral_no", specialist.getReferralNo());
                prop.setProperty("last_name", specialist.getLastName());
                prop.setProperty("first_name", specialist.getFirstName());
                vecRef.add(prop);
            }
        %>
        <select name="f_doctor" <%=getDisabled("f_doctor")%>
                   onChange="changeFamDoc()" style="width: 200px">
        <option value=""></option>
        <% for(int k=0; k<vecRef.size(); k++) {
            prop= (Properties) vecRef.get(k);
        %>
        <option
                value="<%=prop.getProperty("last_name")+","+prop.getProperty("first_name")%>"
                <%=prop.getProperty("referral_no").equals(family_doc)?"selected":""%>>
            <%=Misc.getShortStr( (prop.getProperty("last_name")+","+prop.getProperty("first_name")),"",nStrShowLen)%></option>
        <% }
        %>
    </select> <script type="text/javascript" language="Javascript">
        <!--
        function changeFamDoc() {
            var famName = document.updatedelete.f_doctor.options[document.updatedelete.f_doctor.selectedIndex].value;
            var famNo = "";
            <% for(int k=0; k<vecRef.size(); k++) {
                prop= (Properties) vecRef.get(k);
            %>
            if(famName=="<%=prop.getProperty("last_name")+","+prop.getProperty("first_name")%>") {
                famNo = '<%=prop.getProperty("referral_no", "")%>';
            }
            <% } %>
            document.updatedelete.f_doctor_ohip.value = famNo;
        }
        //-->
    </script> <% } else {%> <input type="text" name="f_doctor" size="17" maxlength="40" <%=getDisabled("f_doctor")%>
                                   value="<%=fam_doc_name%>">
                            <a href="javascript:referralScriptAttach2('f_doctor_ohip','f_doctor', 'f_doctor_id', 'name')"><bean:message key="demographic.demographiceditdemographic.btnSearch"/> Name</a>
                     <% } %>
    </td>
    <td align="right" nowrap><b><bean:message
            key="demographic.demographiceditdemographic.formFamDocNo" />: </b></td>
    <td align="left"><input type="text" name="f_doctor_ohip" <%=getDisabled("f_doctor_ohip")%>
                            size="20" maxlength="6" value="<%=fam_doc_ohip%>"> <% if("ON".equals(prov)) { %>
        <a
                href="javascript:referralScriptAttach2('f_doctor_ohip','f_doctor','f_doctor_id', 'number')"><bean:message key="demographic.demographiceditdemographic.btnSearch"/>
            #</a> <% } %>
    </td>
</tr>
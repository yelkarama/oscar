<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_edoc" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("${ pageContext.request.contextPath }/securityError.jsp?type=_edoc");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ page
	import="java.util.*, oscar.util.*, oscar.OscarProperties, oscar.dms.*, oscar.dms.data.*, org.oscarehr.util.SpringUtils, org.oscarehr.common.dao.CtlDocClassDao"%>
<%--This is included in documentReport.jsp - wasn't meant to be displayed as a separate page --%>
<%
String user_no = (String) session.getAttribute("user");
String appointment = request.getParameter("appointmentNo");

String module = "";
String moduleid = "";
if (request.getParameter("function") != null) {
    module = request.getParameter("function");
    moduleid = request.getParameter("functionid");
} else if (request.getAttribute("function") != null) {
    module = (String) request.getAttribute("function");
    moduleid = (String) request.getAttribute("functionid");
}

String curUser = "";
if (request.getParameter("curUser") != null) {
    curUser = request.getParameter("curUser");
} else if (request.getAttribute("curUser") != null) {
    curUser = (String) request.getAttribute("curUser");
}

OscarProperties props = OscarProperties.getInstance();

AddEditDocumentForm formdata = new AddEditDocumentForm();
formdata.setAppointmentNo(appointment);
String defaultType = (String) props.getProperty("eDocAddTypeDefault", "");
String defaultDesc = "Enter Title"; //if defaultType isn't defined, this value is used for the title/description
String defaultHtml = "Enter Link URL";

if(request.getParameter("defaultDocType") != null) {
	defaultType = request.getParameter("defaultDocType");
}
Hashtable docerrors = new Hashtable();
if (request.getAttribute("docerrors") != null) {
    docerrors = (Hashtable) request.getAttribute("docerrors");
}

Hashtable linkhtmlerrors = new Hashtable();
if (request.getAttribute("linkhtmlerrors") != null) {
    linkhtmlerrors = (Hashtable) request.getAttribute("linkhtmlerrors");
}

//for "add document" link from the patient master page - the "mode" variable allows the add div to open up
String mode = "";
if (request.getAttribute("mode") != null) {
    mode = (String) request.getAttribute("mode");
} else if (request.getParameter("mode") != null) {
    mode = request.getParameter("mode");
}

//Retrieve encounter id for updating encounter navbar if info this page changes anything
String parentAjaxId;
if( request.getParameter("parentAjaxId") != null )
    parentAjaxId = request.getParameter("parentAjaxId");
else if( request.getAttribute("parentAjaxId") != null )
    parentAjaxId = (String)request.getAttribute("parentAjaxId");
else
    parentAjaxId = "";

if (request.getAttribute("completedForm") != null) {
formdata = (AddEditDocumentForm) request.getAttribute("completedForm");
} else {
    formdata.setFunction(module);  //"module" and "function" are the same
    formdata.setFunctionId(moduleid);
    formdata.setDocType(defaultType);
    formdata.setDocDesc(defaultType.equals("")?defaultDesc:defaultType);
    formdata.setDocCreator(user_no);
    formdata.setObservationDate(UtilDateUtilities.DateToString(new Date(), "yyyy-MM-dd"));
    formdata.setHtml(defaultHtml);
    formdata.setAppointmentNo(appointment);
}
ArrayList doctypes = EDocUtil.getActiveDocTypes(formdata.getFunction());

CtlDocClassDao docClassDao = (CtlDocClassDao)SpringUtils.getBean("ctlDocClassDao");
List<String> reportClasses = docClassDao.findUniqueReportClasses();
ArrayList<String> subClasses = new ArrayList<String>();
ArrayList<String> consultA = new ArrayList<String>();
ArrayList<String> consultB = new ArrayList<String>();
for (String reportClass : reportClasses) {
    List<String> subClassList = docClassDao.findSubClassesByReportClass(reportClass);
    if (reportClass.equals("Consultant ReportA")) consultA.addAll(subClassList);
    else if (reportClass.equals("Consultant ReportB")) consultB.addAll(subClassList);
    else subClasses.addAll(subClassList);

    if (!consultA.isEmpty() && !consultB.isEmpty()) {
        for (String partA : consultA) {
            for (String partB : consultB) {
                subClasses.add(partA+" "+partB);
            }
        }
    }
}
%>

 <link rel="stylesheet" href="${ pageContext.request.contextPath }/library/jquery/jquery-ui.theme-1.12.1.min.css">
 <link rel="stylesheet" href="${ pageContext.request.contextPath }/library/jquery/jquery-ui.structure-1.12.1.min.css">
<script src="${ pageContext.request.contextPath }/share/javascript/Oscar.js" type="text/javascript"></script>
<link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->
<script src="${ pageContext.request.contextPath }/share/calendar/calendar.js"></script>
<script src="${ pageContext.request.contextPath }/share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
<script src="${ pageContext.request.contextPath }/share/calendar/calendar-setup.js"></script>

<link rel="stylesheet" type="text/css" media="all"
	href="${ pageContext.request.contextPath }/share/calendar/calendar.css" title="win2k-cold-1" />



<script>


    <%--request attribute "linkhtmlerrors" & "docerrors" is used to check if a document was just submitted --%>
    <% if (request.getAttribute("linkhtmlerrors") != null) { //Open AddLink div%>
    showhide('addLinkDiv', 'plusminusLinkA');
    <%} else if ((request.getAttribute("docerrors") != null) || (!mode.equals(""))) { //Open AddDoc div%>
    showhide('addDocDiv', 'plusminusAddDocA');
    //setFocus();
    <%}%>


  function checkSel(sel){
  theForm = sel.form;
  if ((theForm.docDesc.value == "") || (theForm.docDesc.value == "<%= defaultDesc%>")) {
       theForm.docDesc.value = theForm.docType.value;
       theForm.docDesc.focus();
       theForm.docDesc.select();
  }
}

function checkDefaultValue(object) {
  //selectBoxType = object.form.docType
  //var selectedType = selectBoxType.options[selectBoxType.selectedIndex].value;
  if ((object.value == "<%= defaultDesc%>") || (object.value == "<%= defaultType%>") || (object.value == "<%= defaultHtml %>")) {
      object.value = "";
  }
}

/* no need
function setFocus() {
	var focusTo = document.getElementsByClassName("warning", "topplane");
            if (focusTo[i].type == "text") {
               focusTo[i].focus();
            i = focusTo.length;

           }
            }
}*/

function showhide(hideelement, button) {
    var plus = '<i class="icon-plus"></i>';
    var minus = '<i class="icon-minus"></i>';
    if (document.getElementById) { // DOM3 = IE5, NS6
        if (document.getElementById(hideelement).style.display == 'none') {
              document.getElementById(hideelement).style.display = 'block';
              document.getElementById(button).innerHTML = document.getElementById(button).innerHTML.replace(plus, minus);
              if ((hideelement == "addDocDiv") && (document.getElementById("addLinkDiv").style.display != "none")) {
                   showhide("addLinkDiv", "plusminusLinkA");
              } else if ((hideelement == "addLinkDiv") && (document.getElementById("addDocDiv").style.display != "none")) {
                   showhide("addDocDiv", "plusminusAddDocA");
              }
        }
        else {
              document.getElementById(hideelement).style.display = 'none';
              document.getElementById(button).innerHTML = document.getElementById(button).innerHTML.replace(minus, plus);;
        }
    }
}

function submitUpload(object) {
    object.Submit.disabled = true;
    if (!validDate("observationDate")) {
        alert("Invalid Date: must be in format: yyyy-mm-dd");
        object.Submit.disabled = false;
        return false;
    }
    return true;
}

function submitUploadLink(object) {
    object.Submit.disabled = true;
    return true;
}

//clears default values
function checkDefaultDate(object, defaultValue) {
   if (object.value === defaultValue) {
       object.value = "";
   }
}

function newDocType(){
	var newOpt = prompt("Please enter new document type:", "");

	if(newOpt == null)
		return;

	if (newOpt != "") {
	    document.getElementById("docType").options[document.getElementById("docType").length] = new Option(newOpt, newOpt);
	    document.getElementById("docType").options[document.getElementById("docType").length-1].selected = true;

	    } else {
	    alert("Invalid entry");
	}

}

function newDocTypeLink(){
	var newOpt = prompt("Please enter new document type:", "");

	if(newOpt == null)
		return;

	if (newOpt != "") {
	    document.getElementById("docType1").options[document.getElementById("docType1").length] = new Option(newOpt, newOpt);
	    document.getElementById("docType1").options[document.getElementById("docType1").length-1].selected = true;

	    } else {
	    alert("Invalid entry");
	}

}


</script>
<div class="topplane">
<div class="docHeading" style="background-color: silver;">
    <a id="plusminusAddDocA" href="javascript: showhide('addDocDiv', 'plusminusAddDocA');"> <i class="icon-plus"></i>&nbsp;</a><bean:message key="dms.addDocument.msgAddDocument"/>
    <%-- a id="plusminusAddDocA" href="undocumentReport2.jsp"> <i class="icon-plus"></i>&nbsp;</a><bean:message key="dms.addDocument.msgManageUploadDocument"/> --%>
    <a id="plusminusLinkA" href="javascript: showhide('addLinkDiv', 'plusminusLinkA')"> <i class="icon-plus"></i>&nbsp;</a><bean:message key="dms.addDocument.AddLink"/>
    <a href="javascript:;" onclick="popup(450, 600, 'addedithtmldocument.jsp?function=<%=module%>&functionid=<%=moduleid%>&mode=addHtml', 'addhtml')"><i class="icon-plus"></i>&nbsp</a><bean:message key="dms.addDocument.AddHTML"/>
</div>
<div id="addDocDiv" class="addDocDiv"
	style="background-color: silver; display: none;"><html:form
	action="/dms/addEditDocument" method="POST"
	enctype="multipart/form-data" styleClass="forms"
	onsubmit="return submitUpload(this)">
	<%-- Lists Errors --%>
	<% for (Enumeration errorkeys = docerrors.keys(); errorkeys.hasMoreElements();) {%>
	<font class="warning">Error: <bean:message
		key="<%=(String) docerrors.get(errorkeys.nextElement())%>" /></font>
	<br />
	<% } %>
	<input type="hidden" name="function"
		value="<%=formdata.getFunction()%>" >
	<input type="hidden" name="functionId"
		value="<%=formdata.getFunctionId()%>" >
	<input type="hidden" name="functionid" value="<%=moduleid%>" >
	<input type="hidden" name="parentAjaxId" value="<%=parentAjaxId%>">
	<input type="hidden" name="curUser" value="<%=curUser%>">
	<input type="hidden" name="appointmentNo" value="<%=formdata.getAppointmentNo()%>"/>
	<select id="docType" name="docType" style="width: 160px" >
		<option value=""><bean:message key="dms.addDocument.formSelect" /></option>
		<%
                                   for (int i=0; i<doctypes.size(); i++) {
                                      String doctype = (String) doctypes.get(i); %>
		<option value="<%= doctype%>"
			<%=(formdata.getDocType().equals(doctype))?" selected":""%>><%= doctype%></option>
		<%}%>
	</select>
	<input id="docTypeinput" type="button" class="btn" onClick="newDocType();" value="<bean:message key="dms.documentEdit.formAddNewDocType"/>" />
	<% if (module.equals("provider")) {%>
                                Public: <input type="checkbox"
		name="docPublic" <%=formdata.getDocPublic() + " "%> value="checked">
	<% } %>
	<input type="text" name="docDesc" size="30"
		value="<%=formdata.getDocDesc()%>" onfocus="checkDefaultValue(this)"
		<% if (docerrors.containsKey("descmissing")) {%> class="warning" <%}%>>
	<input type="hidden" name="docCreator"
		value="<%=formdata.getDocCreator()%>" >
	<span class="fieldlabel" title="Observation Date">Obs Date
	(yyyy-mm-dd): </span>
<div class="input-append">
	<input class="span2" type="text" name="observationDate" id="observationDate"
		value="<%=formdata.getObservationDate()%>"
		onclick="checkDefaultDate(this, '<%=UtilDateUtilities.DateToString(new Date(), "yyyy-MM-dd")%>')"
		>
<span class="add-on">
	<a id="obsdate"><img title="Calendar" src="${ pageContext.request.contextPath }/images/cal.gif"
		alt="Calendar" ></a></span>
</div>
	<input type="file" name="docFile"
		<% if (docerrors.containsKey("uploaderror")) {%> class="warning" <%}%>>
	<br />
        <bean:message key="dms.addDocument.msgDocClass"/>:
        <select name="docClass" id="docClass">
            <option value=""><bean:message key="dms.addDocument.formSelectClass"/></option>
<% boolean consult1Shown = false;
for (String reportClass : reportClasses) {
    if (reportClass.startsWith("Consultant Report")) {
        if (consult1Shown) continue;
        reportClass = "Consultant Report";
        consult1Shown = true;
    }
%>
            <option value="<%=reportClass%>"><%=reportClass%></option>
<% } %>
        </select>
        &nbsp;&nbsp;&nbsp;
        <bean:message key="dms.addDocument.msgDocSubClass"/>:
        <input type="text" name="docSubClass" id="docSubClass" style="width:330px">
        <div class="autocomplete_style" id="docSubClass_list"></div>
        &nbsp;
        <input type="checkbox" name="restrictToProgram"> Restrict to current program
        <br /><br>
	<input type="hidden" name="mode" value="add">
	<input type="submit" name="Submit" value="Add" class="btn btn-primary">
	<input type="button" name="Button" class="btn"
		value="<bean:message key="global.btnCancel"/>"
		onclick="javascript: window.location='documentReport.jsp?function=<%=module%>&functionid=<%=moduleid%>'">
</html:form></div>
<div id="addLinkDiv" class="addDocDiv"
	style="background-color: silver; display: none;"><html:form
	action="/dms/addLink" method="POST" styleClass="forms"
	onsubmit="return submitUploadLink(this)"><br><br>
	<%-- Lists Errors --%>
	<% for (Enumeration errorkeys = linkhtmlerrors.keys(); errorkeys.hasMoreElements();) {%>
	<font class="warning">Error: <bean:message
		key="<%=(String) linkhtmlerrors.get(errorkeys.nextElement())%>" /></font>
	<br />
	<% } %>
	<input type="hidden" name="function"
		value="<%=formdata.getFunction()%>" >
	<input type="hidden" name="functionId"
		value="<%=formdata.getFunctionId()%>" >
	<input type="hidden" name="functionid" value="<%=moduleid%>" >
	<input type="hidden" name="observationDate"
		value="<%=formdata.getObservationDate()%>">
		<input type="hidden" name="appointmentNo" value="<%=formdata.getAppointmentNo()%>"/>
	<select id="docType1" name="docType" style="width: 160px" >
 		<option value=""><bean:message key="dms.addDocument.formSelect" /></option>
		<%
         for (int i1=0; i1<doctypes.size(); i1++) {
                                      String doctype = (String) doctypes.get(i1); %>
		<option value="<%= doctype%>"
			<%=(formdata.getDocType().equals(doctype))?" selected":""%>><%= doctype%></option>
		<%}%>
	</select>
	<input id="docTypeinput1" type="button"  onClick="newDocTypeLink();" value="<bean:message key="dms.documentEdit.formAddNewDocType"/>" />
	<% if (module.equals("provider")) {%>
                                Public: <input type="checkbox"
		name="docPublic" <%=formdata.getDocPublic() + " "%> value="checked">
	<% } %>
	<input type="text" name="docDesc" size="30"
		value="<%=formdata.getDocDesc()%>" onfocus="checkDefaultValue(this)"
		<% if (linkhtmlerrors.containsKey("descmissing")) {%> class="warning"
		<%}%>>
	<input type="text" name="html" size="30"
		value="<%=formdata.getHtml()%>" onfocus="checkDefaultValue(this)">
	<input type="hidden" name="docCreator"
		value="<%=formdata.getDocCreator()%>" >
		<input type="hidden" name="appointmentNo" value="<%=formdata.getAppointmentNo()%>"/>
	<br />
        <bean:message key="dms.addDocument.msgDocClass"/>:
        <select name="docClass" id="docClassB">
            <option value=""><bean:message key="dms.addDocument.formSelectClass"/></option>
<% boolean consult2Shown = false;
for (String reportClass : reportClasses) {
    if (reportClass.startsWith("Consultant Report")) {
        if (consult2Shown) continue;
        reportClass = "Consultant Report";
        consult2Shown = true;
    }
%>
            <option value="<%=reportClass%>"><%=reportClass%></option>
<% } %>
        </select>
        &nbsp;&nbsp;&nbsp;
        <bean:message key="dms.addDocument.msgDocSubClass"/>:
        <input type="text" name="docSubClass" id="docSubClass2" style="width:330px">
        <div class="autocomplete_style" id="docSubClass_list2"></div>



        <br />
	<input type="hidden" name="mode" value="addLink">
	<input type="SUBMIT" name="Submit" value="Add">
	<input type="button" name="Button"
		value="<bean:message key="global.btnCancel"/>"
		onclick="javascript: window.location='documentReport.jsp?function=<%=module%>&functionid=<%=moduleid%>'">
</html:form> <script type="text/javascript">
                            Calendar.setup( { inputField : "observationDate", ifFormat : "%Y-%m-%d", showsTime :false, button : "obsdate", singleClick : true, step : 1 } );
                           </script></div>
</div>
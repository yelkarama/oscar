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
<!DOCTYPE html>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>

<html>
<head>
<title>Do you want a cover page?</title>

<link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!--  bootstrap 2.3 -->

</head>
<body style="text-align:center">

<h3>Would you like a cover page?</h3>
<form action="<%=request.getContextPath() + "/oscarEncounter/oscarConsultationRequest/ConsultationFormFax.do"%>" method="post">

<input type="hidden" name="reqId" value="<%=request.getAttribute("reqId")==null ? request.getParameter("reqId") : request.getAttribute("reqId") %>">
<input type="hidden" name="transType" value="<%=request.getAttribute("transType") %>">
<input type="hidden" name="demographicNo" value="<%=request.getParameter("demographicNo")%>">
<input type="hidden" name="letterheadFax" value="<%=request.getParameter("letterheadFax")%>">
<input type="hidden" name="fax" value="<%=request.getParameter("fax")%>">

<%
	String consultResponsePage = request.getParameter("consultResponsePage");
	if (consultResponsePage!=null) {
	%>
		<input type="hidden" name="consultResponsePage" value="<%=consultResponsePage%>"/>
	<%
	}
%>

<%
	String[] faxRecipients = request.getParameterValues("faxRecipients");

	if( faxRecipients != null ) {
		for( String fax : faxRecipients ) {
%>
			<input type="hidden" name="faxRecipients" value="<%=fax%>">
<%
		}
	}
%>


<div class="well">
    <div class="row">
	<label class="control-label" for="yes"><bean:message key="consultationList.btn.newConsult" /></label><bean:message key="global.yes" /><input type="radio" name="coverpage" value="true" id="yes">&nbsp;<bean:message key="global.no" /><input type="radio" checked="checked" name="coverpage" value="false">
    </div>
    <div style="margin-top:25px;">
<bean:message key="caseload.msgNotes" /><br>
	<textarea name="note" style= "width: 80%; height:300px;" onclick="document.getElementById('yes').checked = true;" ></textarea>
<br>
	<input class="btn btn-primary" type="submit" value="<bean:message key="global.btnSubmit" />">
    </div>
</div>

</form>


</body>
</html>
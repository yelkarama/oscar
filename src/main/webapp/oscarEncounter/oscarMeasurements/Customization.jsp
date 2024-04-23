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

<%
  if(session.getValue("user") == null) response.sendRedirect("../../logout.jsp");
%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="oscar.oscarEncounter.pageUtil.*"%>
<%@ page import="oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig"%>
<%@ page import="oscar.oscarEncounter.oscarMeasurements.pageUtil.*"%>
<%@ page import="oscar.OscarProperties"%>
<%@ page import="oscar.util.StringUtils"%>
<%@ page import="java.util.*"%>
<%@ page import="org.owasp.encoder.Encode"%>

<html:html locale="true">
<head>
<html:base />
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message
	key="oscarEncounter.Measurements.msgCustomization" /></title>

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="<%=request.getContextPath()%>/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->
    <script src="${pageContext.servletContext.contextPath}/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/DT_bootstrap.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/bootstrap-responsive.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet">

<script>
function popupOscarConS(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.ConsultChoice.oscarConS"/>", windowprops);
}

</script>
<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />
    <html:form action="/oscarEncounter/oscarMeasurements/DefineNewMeasurementGroup.do" onsubmit="return validateForm()">
        <h3><bean:message key="oscarEncounter.Measurements.msgDefineNewMeasurementGroup" /></h3>
        <div class="well">
			<table>
				<tr>
					<td align="left"><bean:message
						key="oscarEncounter.oscarMeasurements.addMeasurementGroup.createNewMeasurementGroupName" />
					</td>
				</tr>
				<tr>
					<td><html:text property="groupName" styleClass="input-large" /></td>
				</tr>
				<tr>
					<td><bean:message
						key="oscarEncounter.oscarMeasurements.addMeasurementGroup.selectStyleSheet" />
					</td>
				</tr>
				<tr>
					<td><html:select property="styleSheet" style="width:250">
					<html:option value=""></html:option>
						<html:options collection="allStyleSheets" property="cssId"
							labelProperty="styleSheetName" />
					</html:select></td>
				</tr>
				<tr>
					<td>
					<table>
						<tr>
							<td><!--<input type="button" name="Button" class="btn"
						value="<bean:message key="global.btnClose"/>"
						onClick="window.close()">--></td>
							<td><input type="submit" name="submit" class="btn btn-primary"
						value="<bean:message key="oscarEncounter.oscarMeasurements.MeasurementsAction.continueBtn"/>"/></td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
        </div>
    </html:form>
<script>
function validateForm()
{
  var a=document.forms[0]["groupName"].value;
  if (a==null || a==""){
  	alert("Please enter a group name");
  	return false;
  }
}
</script>
</body>
</html:html>
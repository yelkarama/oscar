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
<%@ page import="oscar.oscarEncounter.oscarMeasurements.pageUtil.*"%>
<%@ page import="java.util.Vector"%>
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
<script>

$(document).ready(function(){
    oTable=jQuery('#measTbl').DataTable({
        "order": [],
        "lengthMenu": [ [15, 30, 90, -1], [15, 30, 90, "<bean:message key="oscarEncounter.LeftNavBar.AllLabs"/>"] ],
        "language": {
        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
        }
    });

});

</script>
</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />

    <html:form
	    action="/oscarEncounter/oscarMeasurements/DeleteMeasurementTypes">
        <h3><bean:message key="oscarEncounter.Measurements.msgDisplayMeasurementTypes" /></h3>
        <logic:present name="messages">
            <logic:iterate id="msg" name="messages">
	            <div class="alert-info"><bean:write name="msg" /><a href="#" class="close" data-dismiss="alert">&times;</a></div>
            </logic:iterate>
        </logic:present>
        <table class="table table-compact table-striped" id="measTbl">
            <thead>
	            <tr>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.Measurements.headingType" />
		            </th>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.Measurements.headingDisplayName" />
		            </th>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.Measurements.headingTypeDesc" />
		            </th>
		            <th width="300"><bean:message
			            key="oscarEncounter.oscarMeasurements.Measurements.headingMeasuringInstrc" />
		            </th>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.Measurements.headingValidation" />
		            </th>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.MeasurementAction.headingDelete" />
		            </th>
	            </tr>
            </thead>
            <tbody>
	            <logic:iterate id="measurementType" name="measurementTypes"
		            property="measurementTypeVector" indexId="ctr">
		            <tr class="data">
			            <td><a href="exportMeasurement.jsp?mType=<bean:write name="measurementType" property="type" />"
				            title="<bean:message key="export" />&nbsp;<bean:write name="measurementType" property="type" />"
                            target="_blank" > <bean:write name="measurementType"
				            property="type" /> </a></td>
			            <td><bean:write name="measurementType"
				            property="typeDisplayName" /></td>
			            <td><bean:write name="measurementType"
				            property="typeDesc" /></td>
			            <td><bean:write name="measurementType"
				            property="measuringInstrc" /></td>
			            <td><bean:write name="measurementType"
				            property="validation" /></td>
			            <td><input type="checkbox" name="deleteCheckbox"
				            value="<bean:write name="measurementType" property="id" />"></td>
		            </tr>
	            </logic:iterate>
            </tbody>
        </table>
        <input type="button" name="Button" class="btn"
		    value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.headingDelete"/>"
		    onclick="submit();">
    </html:form>

<!--

    <table>
	    <tr>
		    <td class=Title colspan="2"><bean:message
			    key="oscarEncounter.Measurements.msgGroup" /></td>
	    </tr>
	    <tr>
		    <td>
		    <table>
			    <tr>
				    <td class="messengerButtonsA"><a href=#
    onClick="popupOscarConS(300,1000,'SetupStyleSheetList.do')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.addMeasurementGroup" /></a></td>
			    </tr>
		    </table>
		    </td>
		    <td>
		    <table class=messButtonsA cellspacing=0 cellpadding=3>
			    <tr>
				    <td class="messengerButtonsA"><a href=#
    onClick="popupOscarConS(300,1000,'SetupGroupList.do')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.editMeasurementGroup" /></a></td>
			    </tr>
			    <tr>
				    <td class="messengerButtonsA"><a href=#
    onClick="popupOscarConS(300,1000,'AddMeasurementGroup.do')"
    class="messengerButtons">Add group ik</a></td>
			    </tr>
		    </table>
		    </td>
	    </tr>
	    <tr>
		    <td class=Title colspan="2"><bean:message
			    key="oscarEncounter.Measurements.msgType" /></td>
	    </tr>
	    <tr>
		    <td>
		    <table>
			    <tr>
				    <td class="messengerButtonsA" ><a href=#
    onClick="popupOscarConS(700,1000,'SetupDisplayMeasurementTypes.do')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.viewMeasurementType" /></a></td>
			    </tr>
		    </table>
		    </td>
		    <td>
		    <table>
			    <tr>
				    <td class="messengerButtonsA" width="200"><a href=#
    onClick="popupOscarConS(300,1000,'SetupAddMeasurementType.do')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.addMeasurementType" /></a></td>
			    </tr>
		    </table>
		    </td>
	    </tr>
	    <tr>
		    <td class=Title colspan="2">Mappings --
                    <a href=# onClick="popupOscarConS(300,1000,'viewMeasurementMap.jsp')" class="messengerButtons">View Mapping</a></td>
	    </tr>
	    <tr>
		    <td>
		    <table>
			    <tr>
				    <td class="messengerButtonsA" width="200"><a href=#
    onClick="popupOscarConS(700,1000,'AddMeasurementMap.do')"
    class="messengerButtons">Add Measurement Mapping</a></td>
			    </tr>
		    </table>
		    </td>
		    <td>
		    <table>
			    <tr>
				    <td class="messengerButtonsA" width="200"><a href=#
    onClick="popupOscarConS(600,700,'RemoveMeasurementMap.do')"
    class="messengerButtons">Remove/Remap Measurement Mapping</a></td>
			    </tr>
		    </table>
		    </td>
	    </tr>
	    <tr>
		    <td class=Title colspan="2"><bean:message
			    key="oscarEncounter.Measurements.msgMeasuringInstruction" /></td>
	    </tr>
	    <tr>
		    <td>
		    <table>
			    <tr>
				    <td class="messengerButtonsA" ><a href=#
    onClick="popupOscarConS(300,1000,'SetupAddMeasuringInstruction.do')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.addMeasuringInstruction" /></a>
				    </td>
			    </tr>
		    </table>
		    </td>
	    </tr>
	    <tr>
		    <td class=Title colspan="2"><bean:message
			    key="oscarEncounter.Measurements.msgStyleSheets" /></td>
	    </tr>
	    <tr>
		    <td>
		    <table class=messButtonsA cellspacing=0 cellpadding=3>
			    <tr>
				    <td class="messengerButtonsA" ><a href=#
    onClick="popupOscarConS(300,1000,'SetupDisplayMeasurementStyleSheet.do')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.viewMeasurementStyleSheet" /></a>
				    </td>
			    </tr>
		    </table>
		    </td>
		    <td>
		    <table class=messButtonsA cellspacing=0 cellpadding=3>
			    <tr>
				    <td class="messengerButtonsA" ><a href=#
    onClick="popupOscarConS(300,1000,'AddMeasurementStyleSheet.jsp')"
    class="messengerButtons"><bean:message
    key="oscarEncounter.Index.measurements.addMeasurementStyleSheet" /></a>
				    </td>
			    </tr>
		    </table>
		    </td>
	    </tr>
	    <tr>
		    <td></td>
	    </tr>
    </table>
-->
</body>
</html:html>
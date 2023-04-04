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
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ page import="org.oscarehr.util.LoggedInInfo"%>

<%@ page import="org.w3c.dom.Document"%>
<%@ page import="org.oscarehr.caisi_integrator.ws.CachedDemographicLabResult"%>

<%@ page import="java.util.*"%>
<%@ page import="java.io.Serializable"%>

<%@ page import="oscar.oscarLab.ca.on.*"%>
<%@ page import="oscar.oscarDemographic.data.*"%>
<%@ page import="oscar.oscarLab.ca.all.web.LabDisplayHelper"%>
<%@ page import="org.owasp.encoder.Encode"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%

String labType = request.getParameter("labType");
String demographicNo = request.getParameter("demo");
String testName = request.getParameter("testName");
String identifier = request.getParameter("identifier");
String remoteFacilityIdString = request.getParameter("remoteFacilityId");
String remoteLabKey = request.getParameter("remoteLabKey");

if (identifier == null) identifier = "NULL";

String highlight = "#E0E0FF";

LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

DemographicData dData = new DemographicData();
org.oscarehr.common.model.Demographic demographic =  dData.getDemographic(loggedInInfo, demographicNo);

ArrayList list = null;

if (!(demographicNo == null || demographicNo.equals("null"))){
	if(remoteFacilityIdString==null)
	{
		list = CommonLabTestValues.findValuesForTest(labType, Integer.valueOf(demographicNo), testName, identifier);
	}
	else
	{
		CachedDemographicLabResult remoteLab=LabDisplayHelper.getRemoteLab(loggedInInfo, Integer.parseInt(remoteFacilityIdString), remoteLabKey,Integer.parseInt(demographicNo));
		Document labContentsAsXml=LabDisplayHelper.getXmlDocument(remoteLab);
		HashMap<String, ArrayList<Map<String, Serializable>>> mapOfTestValues=LabDisplayHelper.getMapOfTestValues(labContentsAsXml);
		list=mapOfTestValues.get(identifier);
	}
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
    <html:base />
    <title><bean:message
	    key="oscarMDS.segmentDisplay.title" /></title>


    <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
    <link href="<%=request.getContextPath() %>/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
    <link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
    <link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.dataTables.1.10.11.min.js"></script>

    <script type="text/javascript">
	    jQuery(document).ready( function () {
	        jQuery('#tblDiscs').DataTable({
            "order": [],
	        "bPaginate": false,
            "searching": false
            });
	    });
    </script>

    <style type="text/css">
        .AbnormalRes {
            color: red;
        }
        .LoRes {
            color: blue;
        }
    </style>

    <style type="text/css" media="print">
         .DoNotPrint {
	        display:none;
         }

     </style>
</head>

<script language="JavaScript">
function getComment() {
    var commentVal = prompt('<bean:message key="oscarMDS.segmentDisplay.msgComment"/>', '');
    document.acknowledgeForm.comment.value = commentVal;
    return true;
}

function popupStart(vheight,vwidth,varpage,windowname) {
    var page = varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    var popup=window.open(varpage, windowname, windowprops);
}
</script>

<body>

  <%  if(demographic==null){%>

<script language="JavaScript">
alert("The demographic number is not valid");
window.close();
</script>

    <%} else{%>
<form name="acknowledgeForm" method="post"
	action="../../../oscarMDS/UpdateStatus.do">

<table width="100%" height="100%" border="0" cellspacing="0"
	cellpadding="0">
	<tr>
		<td valign="top">

		<table width="100%" border="1" cellspacing="0" cellpadding="3"
			bgcolor="#9999CC" bordercolordark="#bfcbe3">
			<tr>
				<td width="66%" align="middle" class="Cell">
				<div class="Field2"><bean:message
					key="oscarMDS.segmentDisplay.formDetailResults" /></div>
				</td>
			</tr>
			<tr>
				<td bgcolor="white" valign="top">
				<table valign="top" border="0" cellpadding="2" cellspacing="0"
					width="100%">
					<tr valign="top">
						<td valign="top" width="33%" align="left">
						<table width="100%" border="0" cellpadding="2" cellspacing="0"
							valign="top">
							<tr>
								<td valign="top" align="left">
								<table valign="top" border="0" cellpadding="3" cellspacing="0"
									width="50%">
									<tr>
										<td colspan="2" nowrap>
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formPatientName" />: </strong> <%=Encode.forHtml(demographic.getLastName())%>,
										<%=Encode.forHtml(demographic.getFirstName())%></div>

										</td>
										<td colspan="2" nowrap>
										<div class="FieldData" nowrap="nowrap"><strong><bean:message
											key="oscarMDS.segmentDisplay.formSex" />: </strong><%=Encode.forHtml(demographic.getSex())%>
										</div>
										</td>
									</tr>
									<tr>
										<td colspan="2" nowrap>
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formDateBirth" />: </strong> <%=Encode.forHtml(DemographicData.getDob(demographic,"-"))%>
										</div>
										</td>
										<td colspan="2" nowrap>
										<div class="FieldData" nowrap="nowrap"><strong><bean:message
											key="oscarMDS.segmentDisplay.formAge" />: </strong><%=Encode.forHtml(demographic.getAge())%>
										</div>
										</td>
									</tr>


								</table>
								</td>
								<td width="33%" valign="top"></td>
							</tr>
						</table>
						</td>
					</tr>
				</table>
				</td>

			</tr>

			<tr>
				<td align="center" bgcolor="white" colspan="2">
				<table width="100%" height="20" border="0" cellpadding="0"
					cellspacing="0">
					<tr>
						<td align="center" bgcolor="white">
						<div class="FieldData">
						<center></center>
						</div>
						</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>



		<table style="page-break-inside: avoid;" bgcolor="#003399" border="0"
			cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td colspan="4" height="7">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="4" height="7">&nbsp;</td>
			</tr>

		</table>

		<table width="100%" border="0" cellspacing="0" cellpadding="2"
			bgcolor="#CCCCFF" bordercolor="#9966FF" bordercolordark="#bfcbe3"
			name="tblDiscs" id="tblDiscs" class= "table table-condensed table-striped">
            <thead>
			    <tr class="Field2">
				    <td width="25%" align="middle" valign="bottom" class="Cell"><bean:message
					    key="oscarMDS.segmentDisplay.formTestName" /></td>
				    <td width="10%" align="middle" valign="bottom" class="Cell"><bean:message
					    key="oscarMDS.segmentDisplay.formResult" /></td>
				    <td width="8%" align="middle" valign="bottom" class="Cell"><bean:message
					    key="oscarMDS.segmentDisplay.formAbn" /></td>
				    <td width="15%" align="middle" valign="bottom" class="Cell"><bean:message
					    key="oscarMDS.segmentDisplay.formReferenceRange" /></td>
				    <td width="10%" align="middle" valign="bottom" class="Cell"><bean:message
					    key="oscarMDS.segmentDisplay.formUnits" /></td>
				    <td width="20%" align="middle" valign="bottom" class="Cell"><bean:message
					    key="oscarMDS.segmentDisplay.formDateTimeCompleted" /></td>
			    </tr>
            </thead>
			<%  int linenum = 0;

                            if (list != null){
                               for (int i = 0 ;  i < list.size(); i++){
                                   Map h = (Map) list.get(i);
                                   String lineClass = "NormalRes";
                                   if ( h.get("abn") != null && h.get("abn").equals("A")){
                                      lineClass = "AbnormalRes";
                                   }
                                   if ( h.get("abn") != null && (h.get("abn").equals("L") || h.get("abn").equals("LO")) ){
                                      lineClass = "LoRes";
                                   }
                                   if ( h.get("abn") != null && (h.get("abn").equals("H") || h.get("abn").equals("HI")) ){
                                      lineClass = "AbnormalRes";
                                   }
%>

			<tr class="<%=lineClass%>">
				<td valign="top" align="left"><%=h.get("testName")%></td>
				<td align="right"><%=h.get("result") %></td>
				<td align="center"><%=h.get("abn") %></td>
				<td align="left"><%=h.get("range")%></td>
				<td align="left"><%=h.get("units") %></td>
				<td align="center"><%=h.get("collDate")%></td>
			</tr>

			<%     }
                            } %>

		</table>

		<table width="100%" border="0" cellspacing="0" cellpadding="3"
			class="MainTableBottomRowRightColumn" bgcolor="#003399">
			<tr>
				<td align="left"><input type="button" class="btn DoNotPrint"
					value=" <bean:message key="global.btnClose"/> "
					onClick="window.close()"> <input type="button" class="btn DoNotPrint"
					value=" <bean:message key="global.btnPrint"/> "
					onClick="window.print()">
                               <%-- <input type="button" value="Plot"
                                onclick="window.open('../../../oscarEncounter/GraphMeasurements.do?method=actualLab&demographic_no=<%=demographicNo%>&labType=<%=labType%>&identifier=<%=identifier%>&testName=<%=testName%>');"/>
                                --%>
                               <input type="button" value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.plot"/>" class="btn DoNotPrint"
                                onclick="window.location = 'labValuesGraph.jsp?demographic_no=<%=demographicNo%>&labType=<%=labType%>&identifier=<%=identifier%>&testName=<%=testName%>';"/>

                                </td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</form>
<%}%>
</body>
</html>
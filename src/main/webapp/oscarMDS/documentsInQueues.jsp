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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ page import="java.util.*, oscar.util.*, oscar.OscarProperties, oscar.dms.*, oscar.dms.data.*"%>


<html:html locale="true">
    <head>
    <html:base />
    <title><bean:message key="inboxmanager.documentsInQueues"/></title>

<!-- i18n calendar -->
    <script src="<%=request.getContextPath()%>/share/calendar/calendar.js"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/lang/<bean:message key='global.javascript.calendar'/>"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/calendar-setup.js"></script>
    <link href="<%=request.getContextPath()%>/share/calendar/calendar.css" title="win2k-cold-1" rel="stylesheet" type="text/css" media="all" >

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-ui-1.12.1.min.js"></script>

<!-- oscar -->
    <script src="<%=request.getContextPath()%>/share/javascript/Oscar.js" ></script>
    <script src="<%=request.getContextPath()%>/share/javascript/casemgmt/faxControl.js"> </script>
    <script src="<%=request.getContextPath()%>/js/demographicProviderAutocomplete.js"></script>
    <script src="<%=request.getContextPath()%>/js/documentDescriptionTypeahead.js"></script>
    <script src="<%=request.getContextPath()%>/dms/showDocument.js?ver=1"></script>

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/share/yui/css/fonts-min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">

    <style>
        .Cell{
            background-color:#ADADB3;
        }

        /* Dropdown Button */
        .dropbtns {
        /*  background-color: #4CAF50;
          color: white;
          padding: 16px;
          font-size: 16px;
          border: none;*/
        }

        /* The container <div> - needed to position the dropdown content */
        .dropdowns {
          position: relative;
          display: inline-block;
        }

        /* Dropdown Content (Hidden by Default) */
        .dropdowns-content {
          display: none;
          position: absolute;
          background-color: #f1f1f1;
          min-width: 160px;
          box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
          z-index: 1;
        }

        /* Links inside the dropdown */
        .dropdowns-content a {
          color: black;
          padding: 8px 12px;
          text-decoration: none;
          display: block;
        }

        .dropdowns-content a.disabled {
          pointer-events: none;
          color: grey;
          padding: 8px 12px;
          text-decoration: none;
          display: block;
        }

        /* Change color of dropdown links on hover */
        .dropdowns-content a:hover {background-color: #ddd;}

        /* Show the dropdown menu on hover */
        .dropdowns:hover .dropdowns-content {display: block;}

        /* Change the background color of the dropdown button when the dropdown content is shown */
        .dropdowns:hover .dropbtns {background-color: #e6e6e6;}

    </style>
<script>

var contextpath = "<%=request.getContextPath()%>";

function removeLink(docType, docId, providerNo, e) {
    jQuery.ajax({
        type: "POST",
        url: "<%=request.getContextPath() %>/dms/ManageDocument.do",
        data: 'method=removeLinkFromDocument&docType=' + docType + '&docId=' + docId + '&providerNo=' + providerNo,
        success: function(data) {
            refreshView();
        }
    });
}

function forwardDocument(docId) {
	var frm = "#reassignForm_" + docId;
	var query = jQuery(frm).serialize();

	jQuery.ajax({
		type: "POST",
		url:  "<%= request.getContextPath()%>/oscarMDS/ReportReassign.do",
		data: query,
		success: function (data) {
			refreshView();
		},
		error: function(jqXHR, err, exception) {
			alert("Error " + jqXHR.status + " " + err);
		}
	});
}

function renderCalendar(id,inputFieldId){
    Calendar.setup({ inputField : inputFieldId, ifFormat : "%Y-%m-%d", showsTime :false, button : id });

}

function removeReport(labid) {
	return true;
}

function refreshView() {
	resetCurrentFirstDocLab();
	showDocInQueue(queueID);
}

function refreshAndFile(docId) {
	forceFileDoc(docId);
}

function addDocToList(provNo, provName, docId) {
	var bdoc = document.createElement('a');
	bdoc.setAttribute("onclick", "removeProv(this);");
	bdoc.setAttribute("style", "cursor: pointer;");
	bdoc.appendChild(document.createTextNode(" -remove- "));
	//oscarLog("--");
	var adoc = document.createElement('div');
	adoc.appendChild(document.createTextNode(provName));
	//oscarLog("--==");
	var idoc = document.createElement('input');
	idoc.setAttribute("type", "hidden");
	idoc.setAttribute("name", "flagproviders");
	idoc.setAttribute("value", provNo);

	adoc.appendChild(idoc);

	adoc.appendChild(bdoc);
	var providerList = document.getElementById('providerList' + docId);
	providerList.appendChild(adoc);
}

function getWidth() {
    var myWidth = 0;
    if( typeof( window.innerWidth ) == 'number' ) {
        //Non-IE
        myWidth = window.innerWidth;
    } else if( document.documentElement &&  document.documentElement.clientWidth  ) {
        //IE 6+ in 'standards compliant mode'
        myWidth = document.documentElement.clientWidth;
    } else if( document.body && document.body.clientHeight  ) {
        //IE 4 compatible
        myWidth = document.body.clientWidth;
    }
    return myWidth;
}


function getHeight() {
    var myHeight = 0;
    if( typeof( window.innerHeight ) == 'number' ) {
        //Non-IE
        myHeight = window.innerHeight;
    } else if( document.documentElement && document.documentElement.clientHeight  ) {
        //IE 6+ in 'standards compliant mode'
        myHeight = document.documentElement.clientHeight;
    } else if( document.body && (document.body.clientHeight ) ) {
        //IE 4 compatible
        myHeight = document.body.clientHeight;
    }
    return myHeight;
}

function showPDF(docid,cp) {

    var height=700;
    if(getHeight()>750) {
        height=getHeight()-50;
    }

    var width=700;
    if(getWidth()>1350)
    {
        width=getWidth()-650;
    }

    var url=cp+'/dms/ManageDocument.do?method=display&doc_no='+docid+'&rand='+Math.random()+'#view=fitV&page=1';

    document.getElementById('docDispPDF_'+docid).innerHTML='<object width="'+(width)+'" height="'+(height)+'" type="application/pdf" data="'+url+'" id="docPDF_'+docid+'"></object>';
}

function removeFirstPage(id) {
	jQuery("#removeFirstPagebtn_" + id).attr('disabled', 'disabled');
	var displayDocumentAs=document.getElementById('displayDocumentAs_'+id).value;
    var url = contextpath + "/dms/SplitDocument.do";
    var data = "method=removeFirstPage&document=" + id;
	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (data) {
		    jQuery("#removeFirstPagebtn_" + id).removeAttr('disabled');
            if(displayDocumentAs=="PDF") {
                 showPDF(id,contextpath);
            } else {
                jQuery("#docImg_" + id).attr('src', contextpath + "/dms/ManageDocument.do?method=viewDocPage&doc_no=" + id + "&curPage=1&rand=" + (new Date().getTime()));
            }
		    var numPages = parseInt(jQuery("#numPages_" + id).text())-1;
		    jQuery("#numPages_" + id).text("" + numPages);
    		if (numPages <= 1) {
			    jQuery("#numPages_" + id).removeClass("multiPage");
			    jQuery("#removeFirstPagebtn_" + id).remove();
		    }
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});
}





function rotate180(id) {
	jQuery("#rotate180btn_" + id).attr('disabled', 'disabled');
    var displayDocumentAs=document.getElementById('displayDocumentAs_'+id).value;
    var url = contextpath + "/dms/SplitDocument.do";
    var data = "method=rotate180&document=" + id;
	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (data) {
		    jQuery("#rotate180btn_" + id).removeAttr('disabled');
            if(displayDocumentAs=="PDF") {
                showPDF(id,contextpath);
            } else {
                jQuery("#docImg_" + id).attr('src', contextpath + "/dms/ManageDocument.do?method=viewDocPage&doc_no=" + id + "&curPage=1&rand=" + (new Date().getTime()));
            }
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});


}

function rotate90(id) {
	jQuery("#rotate90btn_" + id).attr('disabled', 'disabled');
	var displayDocumentAs=document.getElementById('displayDocumentAs_'+id).value;
    var url = contextpath + "/dms/SplitDocument.do";
    var data = "method=rotate90&document=" + id;
	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (data) {
		    jQuery("#rotate90btn_" + id).removeAttr('disabled');
            if(displayDocumentAs=="PDF") {
                showPDF(id,contextpath);
            } else {
                jQuery("#docImg_" + id).attr('src', contextpath + "/dms/ManageDocument.do?method=viewDocPage&doc_no=" + id + "&curPage=1&rand=" + (new Date().getTime()));
            }
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});
}

function split(id,demoName) {
	var loc = "<%= request.getContextPath()%>/oscarMDS/Split.jsp?document=" + id + "&queueID=" + queueID + "&demoName=" + demoName;
	popupStart(1400, 1400, loc, "Splitter");
}

var nowChildId;
var nowDocLabIds=[];
var nowMultiple=1;
var queueID;

function showDocInQueue(qid){
    document.getElementById('docs').innerHTML='';
    var docs=queueDocNos[qid];
    nowChildId='docs';
    nowMultiple=1;
    nowDocLabIds=[];
    for(var i=docs.length-1;i>-1;i--){
         var docid=docs[i];
         nowDocLabIds.push(docid);
    }
    queueID = qid;
    showFirstTime();
}
function updateLabDemoStatus(labno){

                                    if(document.getElementById("DemoTable"+labno)){
                                       document.getElementById("DemoTable"+labno).style.backgroundColor="#FFF";
                                    }
                                }




/************init global data methods*****************/

function initQueueIdDocs(s){
    var r=new Array();
    s=s.replace('{','');
    s=s.replace('}','');

}

function initPatientIds(s){
                               var r= new Array();
                               var t=s.split(',');
                               for(var i=0;i<t.length;i++){
                                   var e=t[i];
                                   e.replace(/\s/g,'');
                                   if(e.length>0){
                                       r.push(e);
                                   }
                               }
                               return r;
                           }
                           function initTypeDocLab(s){
                               return initHashtblWithList(s);
                           }
                           function initPatientDocs(s){
                               return initHashtblWithList(s);
                           }
                            function initDocStatus(s){
                               return initHashtblWithString(s);
                           }
                           function initDocType(s){
                               return initHashtblWithString(s);
                           }
                           function initNormals(s){
                               return initList(s);
                           }
                           function initAbnormals(s){
                               return initList(s);
                           }
                           function initPatientIdNames(s){//;1=abc,def;2=dksi,skal;3=dks,eiw
                               var ar=s.split(';');
                               var r=new Object();
                               for(var i=0;i<ar.length;i++){
                                   var e=ar[i];
                                   if(e.length>0){
                                       var ear=e.split('=');
                                       if(ear && ear!=null && ear.length>1){
                                            var k=ear[0];
                                            var v=ear[1];
                                            r[k]=v;
                                        }
                                   }
                               }
                               return r;
                           }
                           function initHashtblWithList(s){//for typeDocLab,patientDocs
                                s=s.replace('{','');
                                s=s.replace('}','');
                                if(s.length>0){
                                var sar=s.split('],');
                                var r=new Object();
                                for(var i=0;i<sar.length;i++){
                                    var ele=sar[i];
                                    ele=ele.replace(/\s/g,'');
                                    var elear=ele.split('=');
                                    var key=elear[0];
                                    var val=elear[1];
                                    val=val.replace('[','');
                                    val=val.replace(']','');
                                    val=val.replace(/\s/g,'');
                                    //console.log(key);
                                    //console.log(val);
                                    var valar=val.split(',');
                                    r[key]=valar;
                                }
                                return r;
                                }else{
                                    return new Object();
                           }

                           }

                           function initHashtblWithString(s){//for docStatus,docType
                                s=s.replace('{','');
                                s=s.replace('}','');
                                s=s.replace(/\s/g,'');
                                var sar=s.split(',');
                                var r=new Object();
                                for(var i=0;i<sar.length;i++){
                                var ele=sar[i];
                                if(ele.length>0){
                                    var ear=ele.split('=');
                                   if(ear.length>0){
                                 var key=ear[0];
                                    var val=ear[1];
                                    r[key]=val;}
                                }}
                                return r;
                           }

                           function initList(s){//normals,abnormals
                                s=s.replace('[','');
                                s=s.replace(']','');
                                s=s.replace(/\s/g,'');
                                if(s.length>0){
                                    var sar=s.split(',');
                                    return sar;
                                }else{
                                    var re=new Array();
                                    return re;
                                }
                           }
                           /********************global data util methods *****************************/
                           function getDocLabFromCat(cat){
                               if(cat.length>0){
                                   return typeDocLab[cat];
                               }
                           }
                           function removeIdFromDocStatus(doclabid){
                               delete docStatus[doclabid];
                           }
                           function removeIdFromDocType(doclabid){
                               if(doclabid&&doclabid!=null){
                                    delete docType[doclabid];
                               }
                           }
                           function removeIdFromTypeDocLab(doclabid){
                               for(var j=0;j<types.length;j++){
                                   var cat=types[j];
                                       var a=typeDocLab[cat];
                                       if(a && a!=null){
                                           if(a.length>0){
                                               var i=a.indexOf(doclabid);
                                               if(i!=-1){
                                                   a.splice(i,1);
                                                   typeDocLab[cat]=a;
                                               }
                                           }else{
                                               delete typeDocLab[cat];
                                           }
                                       }
                               }
                         }
                         function removeNormal(doclabid){
                             var index=normals.indexOf(doclabid);
                             if(index!=-1){
                                 normals.splice(index,1);
                             }
                         }
                         function removeAbnormal(doclabid){
                             var index=abnormals.indexOf(doclabid);
                             if(index!=-1){
                                 abnormals.splice(index,1);
                             }
                         }
                         function removePatientId(pid){
                             if(pid){
                             var i=patientIds.indexOf(pid);
                             //console.log('i='+i+'patientIds='+patientIds);
                             if(i!=-1){
                                 patientIds.splice(i,1);
                             }
                             //console.log(patientIds);
                         }}
                         function removeEmptyPairFromPatientDocs(){
                             var notUsedPid=new Array();
                             for(var i=0;i<patientIds.length;i++){
                                 var pid=patientIds[i];
                                 var e=patientDocs[pid];

                                 if(!e){
                                     notUsedPid.push(pid);
                                 }
                                 else if(e==null || e.length==0){
                                     delete patientDocs[pid];
                                 }
                             }
                             //console.log(notUsedPid);
                             for(var i=0;i<notUsedPid.length;i++){
                                 removePatientId(notUsedPid[i]);//remove pid if it doesn't relate to any doclab
                             }
                         }
                         function removeIdFromPatientDocs(doclabid){
//console.log('in removeidfrompatientdocs'+doclabid);
//console.log(patientIds);
//console.log(patientDocs);
                                for(var i=0;i<patientIds.length;i++){
                                    var pid=patientIds[i];
                                    var a=patientDocs[pid];
                                    //console.log('a');
                                    //console.log(a);
                                    if(a&&a.length>0){
                                        var f=a.indexOf(doclabid);
                                        //console.log('before splice');
                                        //console.log(patientDocs);
                                        if(f!=-1){
                                            a.splice(f, 1);
                                            patientDocs[pid]=a;
                                        }
                                        //console.log('after splice');
                                        //console.log(patientDocs);
                                    }
                                    else{
                                        delete patientDocs[pid];
                                        //console.log('after delete');
                                        //console.log(patientDocs);
                                    }
                                }
                              //console.log('after remove');
                              //console.log(patientDocs);
                         }
                         function addIdToPatient(did,pid){
                             var a=patientDocs[pid];
                             if(a && a!=null){
                                 a.push(did);
                                 patientDocs[pid]=a;
                             }else{
                                 var ar=[did];
                                 patientDocs[pid]=ar;
                             }
                         }
                         function addPatientId(pid){
                             patientIds.push(pid);
                         }
                         function addPatientIdName(pid,name){
                             var n=patientIdNames[pid];
                             if(n || n==null){
                                 patientIdNames[pid]=name;
                             }

                         }

			//first check to see if lab is linked, if it is, we can send the demographicNo to the macro
			function runMacro(name,formid, closeOnSuccess) {
				var num=formid.split("_");
				var doclabid=num[1];
				if(doclabid){
					var demoId=document.getElementById('demofind'+doclabid).value;
					var saved=document.getElementById('saved'+doclabid).value;
					if(demoId=='-1'|| saved=='false'){
						alert('<bean:message key="oscarMDS.index.msgNotAttached"/>');
					}else{
						runMacroInternal(name,formid,closeOnSuccess,demoId);
					}
				}
			}

			function runMacroInternal(name,formid,closeOnSuccess,demographicNo) {
				var url='<%=request.getContextPath()%>'+"/oscarMDS/RunMacro.do?name=" + name + (demographicNo.length>0 ? "&demographicNo=" + demographicNo : "");
	            var data=jQuery('#'+formid).serialize();
                var num=formid.split("_");
	            var labid=num[1];


                jQuery.ajax( {
      	                type: "POST",
      	                url: url,
      	                dataType: "json",
                        data: data,
                        success: function(result) {
                            jQuery('#labdoc_'+labid).hide('fade'); //jQueryUI

	                    }});
			}


function sendMRP(ele){
	var doclabid=ele.id;
	doclabid=doclabid.split('_')[1];
	var demoId=document.getElementById('demofind'+doclabid).value;
	if(demoId=='-1'){
		alert('Please enter a valid demographic');
		ele.checked=false;
	}else{
		if(confirm('Send to Most Responsible Provider?')){
			var type=checkType(doclabid);
			var url=contextpath + "/oscarMDS/SendMRP.do";
			var data='demoId='+demoId+'&docLabType='+type+'&docLabId='+doclabid;

	        jQuery.ajax({
		        type: "POST",
		        url:  url,
		        data: data,
		        success: function (transport) {
				    ele.disabled=true;
				    document.getElementById('mrp_fail_'+doclabid).style.display = 'none';
                },
		        error: function(jqXHR, err, exception) {
			        console.log(jqXHR.status);
				    ele.checked=false;
				    document.getElementById('mrp_fail_'+doclabid).style.display = '';
		        }
	        });


		}else{
			ele.checked=false;
		}
	}
}



function hideTopBtn(){
	document.getElementById('topFRBtn').style.display = 'none';
	if(document.getElementById('topFBtn') && document.getElementById('topFileBtn')){
		document.getElementById('topFBtn').style.display = 'none';
		document.getElementById('topFileBtn').style.display = 'none';
	}
}

function showTopBtn(){
	document.getElementById('topFRBtn').style.display = '';
	if(document.getElementById('topFBtn') && document.getElementById('topFileBtn')){
		document.getElementById('topFBtn').style.display = '';
		document.getElementById('topFileBtn').style.display = '';
	}
}

function changeView(){
    if(document.getElementById('scrollNumber1').getStyle('display')=='none'){
        document.getElementById('scrollNumber1').style.display = '';
        document.getElementById('readerViewTable').style.display = 'none';
        document.getElementById('documentCB').style.display = '';
        document.getElementById('hl7CB').style.display = '';
        document.getElementById('normalCB').style.display = '';
        document.getElementById('abnormalCB').style.display = '';
        document.getElementById('notAssignedDocCB').style.display = '';
        document.getElementById('documentCB2').style.display = '';
        document.getElementById('hl7CB2').style.display = '';
        document.getElementById('normalCB2').style.display = '';
        document.getElementById('abnormalCB2').style.display = '';
        document.getElementById('notAssignedDocCB2').style.display = '';
        var eles=document.getElementsByName('cbText');
            for(var i=0;i<eles.length;i++){
            var ele=eles[i];
            ele.style.display = '';
        }
        showTopBtn();
    }else{
        document.getElementById('scrollNumber1').style.display = 'none';
        document.getElementById('readerViewTable').style.display = '';
        document.getElementById('documentCB').style.display = 'none';
        document.getElementById('hl7CB').style.display = 'none';
        document.getElementById('normalCB').style.display = 'none';
        document.getElementById('abnormalCB').style.display = 'none';
        document.getElementById('notAssignedDocCB').style.display = 'none';
        document.getElementById('documentCB2').style.display = 'none';
        document.getElementById('hl7CB2').style.display = 'none';
        document.getElementById('normalCB2').style.display = 'none';
        document.getElementById('abnormalCB2').style.display = 'none';
        document.getElementById('notAssignedDocCB2').style.display = 'none';
        var eles=document.getElementsByName('cbText');
        for(var i=0;i<eles.length;i++){
            var ele=eles[i];
            ele.style.display = 'none';
        }
        hideTopBtn();
    }
}

function popupMsg(width, height,docid) {
    var dn=document.getElementById('demofind'+docid).value;
    var saved=document.getElementById('saved'+docid).value;
    var b=false;
    //console.log('saved'+saved);
    if(dn==-1 || saved=='false'){
        if(confirm('Document is not linked with a patient, do you still want to Msg?')){
            b=true;
        }
    }else{
        b=true;
    }
    if(b){
         var url='../oscarMessenger/SendDemoMessage.do?'+'demographic_no='+dn;
         popup(width,height,url,'msg');
    }
}

function popupTickler(width, height,docid) {
        var dn=document.getElementById('demofind'+docid).value;
        var saved=document.getElementById('saved'+docid).value;
    if(dn==-1 || saved=='false'){
        alert('Please link document with a patient');
    }else{
        var url="../tickler/ForwardDemographicTickler.do?docType=DOC&demographic_no="+dn+"&docId="+docid;
        popup(width,height,url,'Tickler');
    }
}
function popupStart(vheight,vwidth,varpage) {
    popupStart(vheight,vwidth,varpage,"helpwindow");
}

function popupStart(vheight,vwidth,varpage,windowname) {
        //console.log("in popupstart 4 args");
    //console.log(vheight+"--"+ vwidth+"--"+ varpage+"--"+ windowname);
    if(!windowname)
        windowname="helpwindow";
    //console.log(vheight+"--"+ vwidth+"--"+ varpage+"--"+ windowname);
    var page = varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    var popup=window.open(varpage, windowname, windowprops);
    if (popup != null) {
        if (popup.opener == null) {
            popup.opener = self;
        }
        popup.focus();
    }
}

function reportWindow(page,height,width) {
    //console.log(page);
    if(height && width){
        windowprops="height="+height+", width="+width+", location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0" ;
    }else{
        windowprops="height=800, width=1200, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
    }
    var popup = window.open(page, "labreport", windowprops);
    popup.focus();
}


function submitFile(){
   aBoxIsChecked = false;
   submitLabs = true;
    if (document.reassignForm.flaggedLabs.length == undefined) {
        if (document.reassignForm.flaggedLabs.checked == true) {
            if (document.reassignForm.ackStatus.value == "false"){
                aBoxIsChecked = confirm("The lab for "+document.reassignForm.patientName.value+" has not been attached to a demographic, would you like to file it anyways?");
            }else{
                aBoxIsChecked = true;
            }
        }
    } else {
        for (i=0; i < document.reassignForm.flaggedLabs.length; i++) {
            if (document.reassignForm.flaggedLabs[i].checked == true) {
                if (document.reassignForm.ackStatus[i].value == "false"){
                    aBoxIsChecked = confirm("The lab for "+document.reassignForm.patientName[i].value+" has not been attached to a demographic, would you like to file it anyways?");
                    if(!aBoxIsChecked)
                        break;
                }else{
                    aBoxIsChecked = true;
                }
            }
        }
    }
    if (aBoxIsChecked) {
       document.reassignForm.action = '../oscarMDS/FileLabs.do';
       document.reassignForm.submit();
    }
}


function isRowShown(rowid){
    if(document.getElementById(rowid).style.display=='none')
        return false;
    else
        return true;
}
function checkAll(formId){
   var f = document.getElementById(formId);
   var val = f.checkA.checked;
   for (i =0; i < f.flaggedLabs.length; i++){
       var rowid=getRowIdFromDocLabId(f.flaggedLabs[i].value);
      if(isRowShown(rowid)){//if row is shown
          //oscarLog(f.flaggedLabs[i].value);
      f.flaggedLabs[i].checked = val;
   }
}
}

function wrapUp() {
    if (opener.callRefreshTabAlerts) {
	opener.callRefreshTabAlerts("oscar_new_lab");
	setTimeout("window.close();",100);
    } else {
	window.close();
    }
}



function isNeedShowMore(wh,sd){//input window height and scrool distance , return true if need to scroll down.
    var r=false;
    if(wh*nowMultiple < sd){
        r=true;
        nowMultiple++;
    }
    return r;
}
function showFirstTime(){//show first five doc labs

                for(var i=0;i<5;i++){//show 5
                if(nowDocLabIds.length>0){
                    var id=nowDocLabIds.pop();
                    id=id.replace(" ","");
                    if(id && id.length>0) {
                        var ackStatus=getAckStatusFromDocLabId(id);
                        var patientId=getPatientIdFromDocLabId(id);
                        var patientName=getPatientNameFromPatientId(patientId);
                        if(i==0){if(current_first_doclab==0) current_first_doclab=id;}
                        showDocLab(nowChildId,id,providerNo,searchProviderNo,ackStatus,patientName,queueID);
                    }
                }
            }
}
function bufferAndShow(){//show 5 if scroll down to a certain extend relative to the window
        var wh=f_clientHeight();//window_height
        var sd=f_scrollTop();//scroll_distance
        var showMore=isNeedShowMore(wh,sd);
        if(showMore){
            for(var i=0;i<5;i++){//show 5
                if(nowDocLabIds.length>0){
                    var id=nowDocLabIds.pop();
                    id=id.replace(" ","");
                    if(id && id.length>0) {
                        var ackStatus=getAckStatusFromDocLabId(id);
                        var patientId=getPatientIdFromDocLabId(id);
                        var patientName=getPatientNameFromPatientId(patientId);
                        showDocLab(nowChildId,id,providerNo,searchProviderNo,ackStatus,patientName,queueID);
                    }
                }
            }
        }

}
function f_clientHeight() {
	return f_filterResults (
		window.innerHeight ? window.innerHeight : 0,
		document.documentElement ? document.documentElement.clientHeight : 0,
		document.body ? document.body.clientHeight : 0
	);
}
function f_scrollTop() {
	return f_filterResults (
		window.pageYOffset ? window.pageYOffset : 0,
		document.documentElement ? document.documentElement.scrollTop : 0,
		document.body ? document.body.scrollTop : 0
	);
}
function f_filterResults(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}
       function showDocLab(childId,docNo,providerNo,searchProviderNo,status,demoName,inQueue){//showhide is 0 = document currently hidden, 1=currently shown
                                //create child element in docViews
                                docNo=docNo.replace(' ','');//trim
                                var type=checkType(docNo);
                                //oscarLog('type'+type);
                                //var div=childId;

                                //var div=window.frames[0].document.getElementById(childId);
                                var div=document.getElementById(childId);
                                //alert(div);
                                var url='';
                                if(type=='DOC')
                                    url="../dms/showDocument.jsp";
                                else if(type=='MDS')
                                    url="";
                                else if(type=='HL7')
                                    url="../lab/CA/ALL/labDisplayAjax.jsp";
                                else if(type=='CML')
                                    url="";
                                else
                                    url="";

                                        //oscarLog('url='+url);
                                        var data="segmentID="+docNo+"&providerNo="+providerNo+"&searchProviderNo="+searchProviderNo+"&status="+status+"&demoName="+demoName;
                                        if(inQueue)
                                            data+="&inQueue=" + inQueue;
                                       // oscarLog('url='+url+'+-+ \n data='+data+"----div:"+div);
    jQuery.ajax({
		type: "GET",
		url:  url,
		data: data,
		success: function (code) {
            jQuery("#"+childId+":last-child").append(code);
		    focusFirstDocLab();
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});

                            }

                            function createNewElement(parent,child){
                                //oscarLog('11 create new leme');
                                var newdiv=document.createElement('div');
                                //oscarLog('22 after create new leme');
                                newdiv.setAttribute('id',child);
                               var parentdiv=document.getElementById(parent);
                                parentdiv.appendChild(newdiv);
                                //oscarLog('55 after create new leme');
                            }

         function clearDocView(){
                            var docview=document.getElementById('docViews');
                               //var docview=window.frames[0].document.getElementById('docViews');
                               docview.innerHTML='';
                            }
                                    function showhideSubCat(plus_minus,patientId){
                                if(plus_minus=='plus'){
                                    document.getElementById('plus'+patientId).style.display = 'none';
                                    document.getElementById('minus'+patientId).style.display = '';
                                    document.getElementById('labdoc'+patientId+'showSublist').style.display = '';
                                }else{
                                    document.getElementById('minus'+patientId).style.display = 'none';
                                    document.getElementById('plus'+patientId).style.display = '';
                                    document.getElementById('labdoc'+patientId+'showSublist').style.display = 'none';
                                }
                            }
              function un_bold(ele){
                                //oscarLog('currentbold='+currentBold+'---ele.id='+ele.id);
                                if(currentBold==ele.id){
                                    ;
                                }else{
                                  if(document.getElementById(currentBold)!=null)
                                      document.getElementById(currentBold).style.fontWeight='';
                                    ele.style.fontWeight='bold';
                                    currentBold=ele.id;
                                }
                                //oscarLog('currentbold='+currentBold+'---ele.id='+ele.id);
                            }
                function showPageNumber(page){
                                    var totalNoRow=document.getElementById('totalNumberRow').value;
                                    var newStartIndex=number_of_row_per_page*(parseInt(page)-1);
                                    var newEndIndex=parseInt(newStartIndex)+19;
                                    var isLastPage=false;
                                    if(newEndIndex>totalNoRow){
                                        newEndIndex=totalNoRow;
                                        isLastPage=true;
                                    }
                                    //oscarLog("new start="+newStartIndex+";new end="+newEndIndex);
                                   for(var i=0;i<totalNoRow;i++){
                                       if(document.getElementById('row'+i) && parseInt(newStartIndex)<=i && i<=parseInt(newEndIndex)) {
                                           //oscarLog("show row-"+i);
                                           document.getElementById('row'+i).style.display = '';
                                       }else if(document.getElementById('row'+i)){
                                           //oscarLog("hide row-"+i);
                                           document.getElementById('row'+i).style.display = 'none';
                                       }
                                   }
                               //update current page
                               document.getElementById('currentPageNum').innerHTML=page;
                               if(page==1)
                               {
                                  if(document.getElementById('msgPrevious')) document.getElementById('msgPrevious').style.display = 'none';
                               }else if(page>1){
                                  if(document.getElementById('msgPrevious')) document.getElementById('msgPrevious').style.display = '';
                               }
                               if(isLastPage){
                                    if(document.getElementById('msgNext'))    document.getElementById('msgNext').style.display = 'none';
                               }
                               else{
                                    if(document.getElementById('msgNext'))    document.getElementById('msgNext').style.display = '';
                               }
                           }
                           function showTypePageNumber(page,type){
                               var eles;
                               var numberPerPage=20;
                               if(type=='D'){
                                   eles=document.getElementsByClassName('assignedDoc');
                                   var length=eles.length;
                                   var startindex=(parseInt(page)-1)*numberPerPage;
                                   var endindex=startindex+numberPerPage-1;
                                   if(endindex>length-1){
                                       endindex=length-1;
                                   }
                                   //only display current page
                                   for(var i=startindex;i<endindex+1;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'table-row'});
                                   }
                                   //hide previous page
                                   for(var i=0;i<startindex;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide later page
                                   for(var i=endindex;i<length;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide all labs
                                   eles=document.getElementsByClassName('NormalRes');
                                   eles = eles.concat(document.getElementsByClassName('AbnormalRes'));
                                   for(i=0;i<eles.length;i++){
                                        var ele=eles[i];
                                        ele.setStyle({display:'none'});
                                   }
                               }else if (type=='H'){
                            	   eles=document.getElementsByClassName('NormalRes');
                                   eles = eles.concat(document.getElementsByClassName('AbnormalRes'));
                                   var length=eles.length;
                                   var startindex=(parseInt(page)-1)*numberPerPage;
                                   var endindex=startindex+numberPerPage-1;
                                   if(endindex>length-1){
                                       endindex=length-1;
                                   }
                                   //only display current page
                                   for(var i=startindex;i<endindex+1;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'table-row'});
                                   }
                                   //hide previous page
                                   for(var i=0;i<startindex;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide later page
                                   for(var i=endindex;i<length;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide all labs
                                   eles=document.getElementsByClassName('assignedDoc');
                                   for(i=0;i<eles.length;i++){
                                        var ele=eles[i];
                                        ele.setStyle({display:'none'});
                                   }
                               }else if (type=='N'){
                                    var eles1=filterAb_normal('normal');

                                    var length=eles.length;
                                    var startindex=(parseInt(page)-1)*numberPerPage;
                                    var endindex=startindex+numberPerPage-1;
                                    if(endindex>length-1){
                                           endindex=length-1;
                                    }

                                    for(var i=startindex;i<endindex+1;i++){
                                        var ele=eles1[i];
                                        ele.setStyle({display:'table-row'});
                                    }
                                    //hide previous page
                                    for(var i=0;i<startindex;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide later page
                                   for(var i=endindex;i<length;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide all abnormals
                                    var eles2=filterAb_normal('abnormal');
                                    i=0;
                                    for(i=0;i<eles2.length;i++){
                                        var ele=eles2[i];
                                        ele.setStyle({display:'none'});
                                    }
                               }else if (type=='AB'){
                                    var eles1=filterAb_normal('abnormal');
                                    var length=eles.length;
                                    var startindex=(parseInt(page)-1)*numberPerPage;
                                    var endindex=startindex+numberPerPage-1;
                                    if(endindex>length-1){
                                           endindex=length-1;
                                    }
                                    for(var i=startindex;i<endindex+1;i++){
                                        var ele=eles1[i];
                                        ele.setStyle({display:'table-row'});
                                    }
                                    //hide previous page
                                    for(var i=0;i<startindex;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide later page
                                   for(var i=endindex;i<length;i++){
                                       var ele=eles[i];
                                       ele.setStyle({display:'none'});
                                   }
                                   //hide all normals
                                    var eles2=filterAb_normal('normal');
                                    for(var i=0;i<eles2.length;i++){
                                        var ele=eles2[i];
                                        ele.setStyle({display:'none'});
                                    }
                               }
                           }
                function filterAb_normal(type){//filter normal and abnormal elements from not assigned
                    if(type=='normal'){
                        var n=document.getElementsByClassName('NormalRes');
                        //remove if it's not assigned
                        var r=new Array();
                        for(var i=0;i<n.length;i++){
                            var ele=n[i];
                            if(ele.getAttribute('name')=='notAssignedDoc');
                            else{
                                r.push(ele);
                            }
                        }
                        return r;
                    }else if(type=='abnormal'){
                        var abn=document.getElementsByClassName('AbnormalRes');
                        //remove if it's not assigned
                        var r=new Array();
                        for(var i=0;i<abn.length;i++){
                            var ele=abn[i];
                            if(ele.getAttribute('name')=='notAssignedDoc');
                            else{
                                r.push(ele);
                            }
                        }
                        return r;
                    }
                    return new Array();
                }
                function setTotalRows(){
                               var ds=document.getElementsByClassName('assignedDoc');
                               var ls=document.getElementsByClassName('NormalRes');
                               ls = ls.concat(document.getElementsByClassName('AbnormalRes'));

                               var nd=document.getElementsByClassName('notAssignedDoc');

                               for(var i=0;i<ds.length;i++){
                                   var ele=ds[i];
                                   total_rows.push(ele.id);
                               }
                               for(var i=0;i<ls.length;i++){
                                   var ele=ls[i];
                                   total_rows.push(ele.id);
                               }
                               for(var i=0;i<nd.length;i++){
                                   var ele=nd[i];
                                   total_rows.push(ele.id);
                               }
                               total_rows=sortRowId(uniqueArray(total_rows));

                               current_category=new Array();
                                                        current_category[0]=document.getElementsByClassName('assignedDoc');
                                                        current_category[1]=ls;
                                                        current_category[2]=filterAb_normal('normal');
                                                        current_category[3]=filterAb_normal('abnormal');
                                                        current_category[4]=document.getElementsByClassName('notAssignedDoc');

                           }
                           function checkBox(){

                                                    //oscarLog("in checkBox");
                                                    var checkedArray=new Array();
                                                    if(document.getElementById('documentCB').checked==1){
                                                        checkedArray.push('assignedDoc');
                                                    }
                                                    if(document.getElementById('hl7CB').checked==1){
                                                        checkedArray.push('hl7');
                                                    }
                                                    if(document.getElementById('normalCB').checked==1){
                                                        checkedArray.push('normal');
                                                    }
                                                    if(document.getElementById('abnormalCB').checked==1){
                                                        checkedArray.push('abnormal');
                                                    }
                                                    if(document.getElementById('notAssignedDocCB').checked==1){
                                                        checkedArray.push('notAssignedDoc');
                                                    }
                                                    //console.log('length='+checkedArray.length);
                                         if(checkedArray.length==5){//show all

                                                        var endindex= number_of_row_per_page-1;
                                                        if(endindex>=total_rows.length)
                                                            endindex=total_rows.length-1;

                                                        //show all
                                                        for(var i=0;i<endindex+1;i++){
                                                            var id=total_rows[i];
                                                            if(document.getElementById(id)){
                                                                document.getElementById(id).style.display = '';
                                                            }
                                                        }
                                                        for(var i=endindex+1;i<total_rows.length;i++){
                                                            var id=total_rows[i];
                                                            if(document.getElementById(id)){
                                                                document.getElementById(id).style.display = 'none';
                                                            }
                                                        }
                                                        current_numberofpages=Math.ceil(total_rows.length/number_of_row_per_page);
                                                        initializeNavigation();
                                                        current_category=new Array();
                                                        current_category[0]=document.getElementsByClassName('assignedDoc');
                                                        var labs=document.getElementsByClassName('NormalRes');
                                                        labs = labs.concat(document.getElementsByClassName('AbnormalRes'));
                                                        current_category[1]=labs;
                                                        current_category[2]=filterAb_normal('normal');
                                                        current_category[3]=filterAb_normal('abnormal');
                                                        current_category[4]=document.getElementsByClassName('notAssignedDoc');
//                                                        console.log(current_category[0]);
//                                                        console.log(current_category[1]);
//                                                        console.log(current_category[2]);
//                                                        console.log(current_category[3]);
//                                                        console.log(current_category[4]);
                                           }
                                            else{
                                                        //oscarLog('checkedArray='+checkedArray);
                                                        var eles=new Array();
                                                    for(var i=0;i<checkedArray.length;i++){
                                                        var type=checkedArray[i];

                                                        if(type=='assignedDoc'){
                                                            var docs=document.getElementsByClassName('assignedDoc');
                                                            eles.push(docs);
                                                        }
                                                        else if(type=='hl7'){
                                                            var labs=document.getElementsByClassName('NormalRes');
                                                            labs = labs.concat(document.getElementsByClassName('AbnormalRes'));
                                                            eles.push(labs);
                                                        }
                                                        else if(type=='normal'){
                                                            var norm=filterAb_normal('normal');
                                                            eles.push(norm);
                                                        }
                                                        else if(type=='abnormal'){
                                                            var abn=filterAb_normal('abnormal');
                                                            eles.push(abn);
                                                        }
                                                        else if(type=='notAssignedDoc'){
                                                            var nd=document.getElementsByClassName('notAssignedDoc');
                                                            eles.push(nd);
                                                        }
                                                    }
                                                    current_category=eles;
                                                    displayCategoryPage(1);
                                                    initializeNavigation();
                                                }
                                            }

                                            function displayCategoryPage(page){

                                                //oscarLog('in displaycategorypage, page='+page);
                                                //write all row ids to an array
                                                var displayrowids=new Array();

                                                    for(var p=0;p<current_category.length;p++){
                                                        var elements=new Array();
                                                        elements=current_category[p];
                                                        //oscarLog("elements.lenght="+elements.length);

                                                        for(var j=0;j<elements.length;j++){
                                                            var e=elements[j];
                                                            var rowid=e.id;
                                                            displayrowids.push(rowid);
                                                        }
                                                    }
                                                    //make array unique
                                                    displayrowids=uniqueArray(displayrowids);
                                                    displayrowids=sortRowId(displayrowids);
                                                    //oscarLog('sort and unique displaywords='+displayrowids);

                                                    var numOfRows=displayrowids.length;
                                                    //oscarLog(numOfRows);
                                                    current_numberofpages=Math.ceil(numOfRows/number_of_row_per_page);
                                                    //oscarLog(current_numberofpages);
                                                    var startIndex=(parseInt(page)-1)*number_of_row_per_page;
                                                    var endIndex=startIndex+(number_of_row_per_page-1);
                                                    if(endIndex>displayrowids.length-1){
                                                        endIndex=displayrowids.length-1;
                                                    }
                                                    //set current displaying rows
                                                    current_rows=new Array();

                                                    for(var i=startIndex;i<endIndex+1;i++){
                                                        if(document.getElementById(displayrowids[i])){
                                                            current_rows.push(displayrowids[i]);
                                                        }
                                                    }

                                                    if(current_rows.length<20)//show blank row to fill in empty space
                                                        document.getElementById('blankrow').style.display = '';
                                                    else document.getElementById('blankrow').style.display = 'none';
                                                    //loop through every thing,if it's in displayrowids, show it , if it's not hide it.
                                                    for(var i=0;i<total_rows.length;i++){
                                                        var rowid=total_rows[i];
                                                        if(a_contain_b(current_rows,rowid)){
                                                            if(document.getElementById(rowid)) document.getElementById(rowid).style.display = '';
                                                        }else
                                                            if(document.getElementById(rowid)) document.getElementById(rowid).style.display = 'none';
                                                    }
                                            }

                                            function initializeNavigation(){
                                                   document.getElementById('currentPageNum').innerHTML=1;
                                                    //update the page number shown and update previous and next words
                                                    if(current_numberofpages>1){
                                                       if(document.getElementById('msgNext'))   document.getElementById('msgNext').style.display = '';
                                                       if(document.getElementById('msgPrevious'))   document.getElementById('msgPrevious').style.display = 'none';
                                                    }else if(current_numberofpages<1){
                                                       if(document.getElementById('msgNext'))   document.getElementById('msgNext').style.display = 'none';
                                                       if(document.getElementById('msgPrevious'))    document.getElementById('msgPrevious').style.display = 'none';
                                                    }else if(current_numberofpages==1){
                                                       if(document.getElementById('msgNext'))   document.getElementById('msgNext').style.display = 'none';
                                                       if(document.getElementById('msgPrevious'))    document.getElementById('msgPrevious').style.display = 'none';
                                                    }
                                                    //oscarLog("current_numberofpages "+current_numberofpages);
                                                    if(document.getElementById('current_individual_pages'))   document.getElementById('current_individual_pages').innerHTML="";
                                                   if(current_numberofpages>1){
                                                	   var html = "";
                                                       for(var i=1;i<=current_numberofpages;i++){
                                                        if(document.getElementById('current_individual_pages'))  html+="<a style=\"text-decoration:none;\" href=\"javascript:void(0);\" onclick=\"navigatePage("+i+")\"> [ "+i+" ] </a>";
                                                       }
                                                       document.getElementById('current_individual_pages').update(html);
                                                   }
                                            }
                                            function sortRowId(a){
                                                    var numArray=new Array();
                                                    //sort array
                                                    for(var i=0;i<a.length;i++){
                                                        var id=a[i];
                                                        var n=id.replace('row','');
                                                        numArray.push(parseInt(n));
                                                    }
                                                    numArray.sort(function(a,b){return a-b;});
                                                    a=new Array();
                                                    for(var i=0;i<numArray.length;i++){
                                                        a.push('row'+numArray[i]);
                                                    }
                                                    return a;
                                            }
                                            function a_contain_b(a,b){//a is an array, b maybe an element in a.
                                                for(var i=0;i<a.length;i++){
                                                    if(a[i]==b){
                                                        return true;
                                                    }
                                                }
                                                return false;
                                            }

                                            function uniqueArray(a){
                                                var r=new Array();
                                                o:for(var i=0,n=a.length;i<n;i++){
                                                    for(var x=0,y=r.length;x<y;x++){
                                                        if(r[x]==a[i]) continue o;
                                                    }
                                                    r[r.length]=a[i];
                                                }
                                                return r;
                                            }

                                            function navigatePage(p){
                                                var pagenum=parseInt(document.getElementById('currentPageNum').innerHTML);
                                                if(p=='Previous'){
                                                    displayCategoryPage(pagenum-1);
                                                    document.getElementById('currentPageNum').innerHTML=pagenum-1
                                                }
                                                else if(p=='Next'){
                                                    displayCategoryPage(pagenum+1);
                                                    document.getElementById('currentPageNum').innerHTML=pagenum+1
                                                }
                                                else if(parseInt(p)>0){
                                                    displayCategoryPage(parseInt(p));
                                                    document.getElementById('currentPageNum').innerHTML=p;
                                                }
                                                changeNavigationBar();
                                            }
                                            function changeNavigationBar(){
                                                var pagenum=parseInt(document.getElementById('currentPageNum').innerHTML);
                                                if(current_numberofpages==1){
                                                    if(document.getElementById('msgNext'))  document.getElementById('msgNext').style.display = 'none';
                                                   if(document.getElementById('msgPrevious'))    document.getElementById('msgPrevious').style.display = 'none';
                                                }
                                                else if(current_numberofpages>1 && current_numberofpages==pagenum){
                                                    if(document.getElementById('msgNext'))  document.getElementById('msgNext').style.display = 'none';
                                                    if(document.getElementById('msgPrevious'))   document.getElementById('msgPrevious').style.display = '';
                                                }
                                                else if(current_numberofpages>1 && pagenum==1){
                                                    if(document.getElementById('msgNext'))  document.getElementById('msgNext').style.display = '';
                                                    if(document.getElementById('msgPrevious'))   document.getElementById('msgPrevious').style.display = 'none';
                                                }else if(pagenum<current_numberofpages && pagenum>1){
                                                    if(document.getElementById('msgNext'))  document.getElementById('msgNext').style.display = '';
                                                    if(document.getElementById('msgPrevious'))   document.getElementById('msgPrevious').style.display = '';
                                                }
                                            }
                                            function syncCB(ele){
                                                var id=ele.id;
                                                if(id=='documentCB'){
                                                    if(ele.checked==1)
                                                        document.getElementById('documentCB2').checked=1;
                                                    else
                                                        document.getElementById('documentCB2').checked=0;
                                                }
                                                else if(id=='documentCB2'){
                                                    if(ele.checked==1)
                                                        document.getElementById('documentCB').checked=1;
                                                    else
                                                        document.getElementById('documentCB').checked=0;
                                                }
                                                else if(id=='notAssignedDocCB'){
                                                    if(ele.checked==1)
                                                        document.getElementById('notAssignedDocCB2').checked=1;
                                                    else
                                                        document.getElementById('notAssignedDocCB2').checked=0;
                                                }
                                                else if(id=='notAssignedDocCB2'){
                                                    if(ele.checked==1)
                                                        document.getElementById('notAssignedDocCB').checked=1;
                                                    else
                                                        document.getElementById('notAssignedDocCB').checked=0;
                                                }
                                                else if(id=='hl7CB'){
                                                    if(ele.checked==1)
                                                        document.getElementById('hl7CB2').checked=1;
                                                    else
                                                        document.getElementById('hl7CB2').checked=0;
                                                }
                                                else if(id=='hl7CB2'){
                                                    if(ele.checked==1)
                                                        document.getElementById('hl7CB').checked=1;
                                                    else
                                                        document.getElementById('hl7CB').checked=0;
                                                }
                                                else if(id=='normalCB'){
                                                    if(ele.checked==1)
                                                        document.getElementById('normalCB2').checked=1;
                                                    else
                                                        document.getElementById('normalCB2').checked=0;
                                                }
                                                else if(id=='normalCB2'){
                                                    if(ele.checked==1)
                                                        document.getElementById('normalCB').checked=1;
                                                    else
                                                        document.getElementById('normalCB').checked=0;
                                                }
                                                else if(id=='abnormalCB'){
                                                    if(ele.checked==1)
                                                        document.getElementById('abnormalCB2').checked=1;
                                                    else
                                                        document.getElementById('abnormalCB2').checked=0;
                                                }
                                                else if(id=='abnormalCB2'){
                                                    if(ele.checked==1)
                                                        document.getElementById('abnormalCB').checked=1;
                                                    else
                                                        document.getElementById('abnormalCB').checked=0;
                                                }
                                            }
                        function showAb_Normal(ab_normal){

                                var ids=new Array();
                                if(ab_normal=='normal'){
                                    ids=normals;
                                }
                                else if(ab_normal=='abnormal'){
                                    ids=abnormals;
                                }
                                var childId;
                                if(ab_normal=='normal'){
                                    childId='normals';
                                }else if (ab_normal=='abnormal'){
                                    childId='abnormals';
                                }
                                //oscarLog(childId);
                                if(childId!=null && childId.length>0){
                                      clearDocView();
                                        createNewElement('docViews',childId);
                                        nowChildId=childId;
                                        nowMultiple=1;
                                        nowDocLabIds=new Array();
                                        //console.log("nowDocLabIds");
                                        //console.log(ids);
                                        for(var i=ids.length-1;i>-1;i--){//push in reverse so pop first to last
                                            var docLabId=ids[i].replace(/\s/g,'');
                                            //console.log(docLabId);
                                            nowDocLabIds.push(docLabId);
                                            //console.log(nowDocLabIds);
                                        }
                                        //console.log(nowDocLabIds);
                                        showFirstTime();
                                }
                           }

                                 function showSubType(patientId,subType){
                                    var labdocsArr=getLabDocFromPatientId(patientId);
                                if(labdocsArr && labdocsArr!=null){
                                    var childId='subType'+subType+patientId;
                                    if(labdocsArr.length>0){
                                        //if(toggleElement(childId));
                                     // else{
                                     clearDocView();
                                        createNewElement('docViews',childId);
                                        nowChildId=childId;
                                        nowMultiple=1;
					nowDocLabIds=new Array();
                                        for(var i=labdocsArr.length-1;i>-1;i--){
                                            var labdoc=labdocsArr[i];
                                            labdoc=labdoc.replace(' ','');
                                            //oscarLog('check type input='+labdoc);
                                            var type=checkType(labdoc);

                                            //oscarLog("type="+type+"--subType="+subType);
                                            if(type==subType){
                                                nowDocLabIds.push(labdoc);
                                            }

                                        }
                                        showFirstTime();
                                        //toggleMarker('subtype'+subType+patientId+'show');
                                    //}
                                  }
                                }
                            }
function getPatientNameFromPatientId(patientId){
	var pn=patientIdNames[patientId];
	if(pn&&pn!=null){
		return pn;
	}else{
		var url=contextpath+"/dms/ManageDocument.do";
		var data='method=getDemoNameAjax&demo_no='+patientId;

	    jQuery.ajax({
		    type: "POST",
		    url:  url,
		    data: data,
		    success: function (transport) {
			    var json=jQuery.parseJSON(transport);
			    if(json!=null ){
				    var pn=json.demoName;//get name from id
				    addPatientIdName(patientId,pn);
				    addPatientId(patientId);
				    return pn;
			    }
        	},
		    error: function(jqXHR, err, exception) {
			    console.log(jqXHR.status);
		    }
	    });
    }
}


                            function getAckStatusFromDocLabId(docLabId){
                                return docStatus[docLabId];
                            }
                            function showAllDocLabs(){



                                clearDocView();
                                var childId='showTotalDocLabs';
                                createNewElement('docViews',childId);
                                nowChildId=childId;
                                nowMultiple=1;
                                nowDocLabIds=new Array();
                                for(var i=0;i<patientIds.length;i++){
                                    var id=patientIds[i];
                                    //oscarLog("ids in showalldoclabs="+id);
                                    if(id.length>0){
                                            //oscarLog("patientId in show this patientdocs="+patientId);
                                            var labDocsArr=getLabDocFromPatientId(id);
                                            if(labDocsArr!=null && labDocsArr.length>0){
                                                    for(var j=labDocsArr.length-1;j>-1;j--){
                                                        var docId=labDocsArr[j].replace(' ', '');
                                                        nowDocLabIds.push(docId);
                                                    }
                                            }
                                    }
                                }
                                showFirstTime();
                            }
                            function showCategory(cat){//show in document or hl7
                                if(cat.length>0){
                                     var sA=getDocLabFromCat(cat);
                                     if(sA && sA.length>0){
                                         //oscarLog("sA="+sA);
                                         var childId="category"+cat;
                                         //if(toggleElement(childId));
                                        // else{
                                         clearDocView();
                                         createNewElement('docViews',childId);
                                         nowChildId=childId;
                                         nowMultiple=1;
                                         nowDocLabIds=new Array();
                                         for(var i=sA.length-1;i>-1;i--){
                                             var docLabId=sA[i];
                                             docLabId=docLabId.replace(/\s/g, "");
                                             nowDocLabIds.push(docLabId);
                                         }
                                         showFirstTime();
                                     }
                                }
                            }

                            function getPatientIdFromDocLabId(docLabId){
                                //console.log('in getpatientidfromdoclabid='+docLabId);
                                //console.log(patientIds);
                                //console.log(patientDocs);
                                var notUsedPid=new Array();
                                for(var i=0;i<patientIds.length;i++){

                                    var pid=patientIds[i];
                                    var e=patientDocs[pid];
                                    //console.log('e'+e);
                                    if(!e){
                                        //console.log('if');
                                        notUsedPid.push(pid);
                                    }else{
                                        //console.log('in else='+docLabId);
                                        if(e.indexOf(docLabId)>-1){
                                            return pid;
                                        }
                                    }
                                }
                                //console.log(notUsedPid);
                                for(var i=0;i<notUsedPid.length;i++){
                                    removePatientId(notUsedPid[i]);
                                }
                            }
                            function getLabDocFromPatientId(patientId){//return array of doc ids and lab ids from patient id.
                                //console.log(patientId+"--");
                                //console.log(patientDocs);
                                return patientDocs[patientId];
                            }
                            function showThisPatientDocs(patientId,keepPrevious){//show doclabs belong to this patient
                                //oscarLog("patientId in show this patientdocs="+patientId);
                                var labDocsArr=getLabDocFromPatientId(patientId);
                                var patientName=getPatientNameFromPatientId(patientId);
                                if(patientName!=null && patientName.length>0 && labDocsArr!=null && labDocsArr.length>0){
                                        //oscarLog(patientName);
                                        var childId='patient'+patientId;
                                      //if(toggleElement(childId));
                                      //else{
                                      //if(keepPrevious);
                                       clearDocView();
                                        createNewElement('docViews',childId);
                                        nowChildId=childId;
                                        nowMultiple=1;
                                        nowDocLabIds=new Array();
                                        for(var i=labDocsArr.length-1;i>-1;i--){
                                            var docId=labDocsArr[i].replace(' ', '');
                                            nowDocLabIds.push(docId);
                                        }
                                        showFirstTime();
                                }
                            }
                            function popupConsultation(segmentId) {
                            	  var page =contextpath+ '/oscarEncounter/ViewRequest.do?segmentId='+segmentId;
                            	  var windowprops = "height=960,width=700,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
                            	  var popup=window.open(page, msgConsReq, windowprops);
                            	  if (popup != null) {
                            	    if (popup.opener == null) {
                            	      popup.opener = self;
                            	    }
                            	  }
                           }

                           function checkType(docNo){
                                return docType[docNo];
                           }
function checkSelected() {

    //oscarLog('in checkSelected()');
    aBoxIsChecked = false;
    if (document.reassignForm.flaggedLabs.length == undefined) {
        if (document.reassignForm.flaggedLabs.checked == true) {
            aBoxIsChecked = true;
        }
    } else {
        for (i=0; i < document.reassignForm.flaggedLabs.length; i++) {
            if (document.reassignForm.flaggedLabs[i].checked == true) {
                //oscarLog(document.reassignForm.flaggedLabs[i].value);
                aBoxIsChecked = true;
            }
        }
    }
    if (aBoxIsChecked) {
        popupStart(397, 700, '../oscarMDS/SelectProvider.jsp', 'providerselect');
    } else {
        alert(msgSelectOneLab);
    }
}

function updateDocLabData(doclabid,inQueue){//remove doclabid from global variables
//console.log('in updatedoclabdata='+doclabid);
  if(doclabid){
      //console.log('aa');
       //trim doclabid
      doclabid=doclabid.replace(/\s/g,'');
        updateSideNav(doclabid,inQueue);
        //console.log('aa_aa11');
      if(inQueue){;}
       else  hideRowUsingId(doclabid);
//console.log('aa_aa');
    //change typeDocLab
    removeIdFromTypeDocLab(doclabid);
//console.log('bb');
    //change docType
    removeIdFromDocType(doclabid);
    //console.log('cc');
    //change patientDocs
    removeIdFromPatientDocs(doclabid);
    //console.log('dd');

    //change patientIdNames and patientIdStr
    removeEmptyPairFromPatientDocs();
    //console.log('ee');

    //change docStatus
    removeIdFromDocStatus(doclabid);
    //console.log('ff');

    //remove from normals
    removeNormal(doclabid);
    //remove from abnormals
    removeAbnormal(doclabid);

/*console.log(typeDocLab);
                           console.log(docType);
                           console.log(patientDocs);
                           console.log(patientIdNames);
                           console.log(patientIds);
                           console.log(docStatus);
                           console.log(normals);*/

  }
}
function checkAb_normal(doclabid){
    if(normals.indexOf(doclabid)!=-1)
        return 'normal';
    else if(abnormals.indexOf(doclabid)!=-1)
        return 'abnormal';
}
function removeDocFromQueue(docid){
    //console.log('before removal ');
    //console.log(queueDocNos);
    var found=false;
    for(i in queueDocNos){
        var r=queueDocNos[i];
        //console.log('when r is ');
        //console.log(r);
        for(var j=0;j<r.length;j++){
            if(r[j]==docid){
                //remove it
                r.splice(j,1);
                //console.log('after splice, j is'+j);
                //console.log(r);
                queueDocNos[i]=r;
                found=true;
                break;
            }else{

            }
        }
        if(found)
            break;//break the outer for loop.
    }
    //console.log('after removal ');
    //console.log(queueDocNos);
}

function updateSideNavInQueue(docid){
//console.log('in updateSide');
    var foundQ='';
    //find which queueid the doc is in
for(var i in queueDocNos){
    var r=queueDocNos[i];
    for(var j=0;j<r.length;j++){
        if(r[j]==docid){
            foundQ=i;
            //console.log('match found foundQ='+foundQ);
            break;
        }
    }
    if(foundQ==i)
        break;
}
//console.log('foundQ='+foundQ);
        //descrease the queue's doc number by 1
        if(foundQ.length>0){
            var n=document.getElementById('docNo_'+foundQ).innerHTML;
            //console.log('not found11');
            n=parseInt(n);
            //console.log('not found22');
            if(n>0){
                //console.log('not found33');
                document.getElementById('docNo_'+foundQ).innerHTML=n-1;
            }
        }
        //console.log('not found44');

}
function updateSideNav(doclabid, inqueue){
    if(inqueue)
        updateSideNavInQueue(doclabid);
    else{
    //oscarLog('in updatesidenav');
    var n=document.getElementById('totalNumDocs').innerHTML;
    n=parseInt(n);
    if(n>0){
        n=n-1;
        document.getElementById('totalNumDocs').innerHTML=n;
    }
    var type=checkType(doclabid);
    //oscarLog('type='+type);
    if(type=='DOC'){
        n=document.getElementById('totalDocsNum').innerHTML;
        //oscarLog('n='+n);
        n=parseInt(n);
        if(n>0){
            n=n-1;
            document.getElementById('totalDocsNum').innerHTML=n;
        }
    }else if (type=='HL7'){
        n=document.getElementById('totalHL7Num').innerHTML;
        n=parseInt(n);
        if(n>0){
            n=n-1;
            document.getElementById('totalHL7Num').innerHTML=n;
        }
    }
    var ab_normal=checkAb_normal(doclabid);
    //oscarLog('normal or abnormal?'+ab_normal);
    if(ab_normal=='normal'){
        n=document.getElementById('normalNum').innerHTML;
        //oscarLog('normal inner='+n);
        n=parseInt(n);
        if(n>0){
            n=n-1;
            document.getElementById('normalNum').innerHTML=n;
        }
    }else if(ab_normal=='abnormal'){
        n=document.getElementById('abnormalNum').innerHTML;
        n=parseInt(n);
        if(n>0){
            n=n-1;
            document.getElementById('abnormalNum').innerHTML=n;
        }
    }

    //update patient and patient's subtype
    var patientId=getPatientIdFromDocLabId(doclabid);
    //oscarLog('xx '+patientId+'--'+n);
    n=document.getElementById('patientNumDocs'+patientId).innerHTML;
    //oscarLog('xx xx '+patientId+'--'+n);
    n=parseInt(n);
    if(n>0){
        document.getElementById('patientNumDocs'+patientId).innerHTML=n-1;
    }

    if(type=='DOC'){
        n=document.getElementById('pDocNum_'+patientId).innerHTML;
        n=parseInt(n);
        if(n>0){
            document.getElementById('pDocNum_'+patientId).innerHTML=n-1;
        }
    }
    else if(type=='HL7'){
        n=document.getElementById('pLabNum_'+patientId).innerHTML;
        n=parseInt(n);
        if(n>0){
            document.getElementById('pLabNum_'+patientId).innerHTML=n-1;
        }
    }
}
}
function getRowIdFromDocLabId(doclabid){
        var rowid;

        for(var i=0;i<doclabid_seq.length;i++){
            if(doclabid==doclabid_seq[i]){
                rowid='row'+i;
                break;
            }
        }
    return rowid;
    }

function hideRowUsingId(doclabid){
    if(doclabid!=null ){
        var rowid;
        doclabid=doclabid.replace(' ','');
        rowid=getRowIdFromDocLabId(doclabid);
        if(document.getElementById(rowid)) document.getElementById(rowid).remove();
}
}
function resetCurrentFirstDocLab(){
    current_first_doclab=0;
}

function focusFirstDocLab(){
    if(current_first_doclab>0){
            var doc_lab=checkType(current_first_doclab);
            if(doc_lab=='DOC'){
                //oscarLog('docDesc_'+current_first_doclab);
                document.getElementById('docDesc_'+current_first_doclab).focus();
            }
            else if(doc_lab=='HL7'){
                //do nothing
            }
        }
    }

/***methos for showDocument.jsp***/
function addDocToPatient(doclabid,patientId){//if doc is previously not assigned to a patient, add it to a patient's list of docs
                                         doclabid=doclabid.replace(/\s/g,'');
                                         if(doclabid.length>0){
                                                               //delete doclabid from not assigned list
                                                               var na=patientDocs['-1'];
                                                               var index=na.indexOf(doclabid);
                                                               if(index!=-1){
                                                                   na.splice(index,1);
                                                                   addIdToPatient(doclabid,patientId);//add to patient
                                                               }
                                                               return true;
                                         }
                                  }
    function  updatePatientDocLabNav(num,patientId){
                                     //oscarLog(num+';;'+patientId);
                                     if(num && patientId){
                                         var changed=false;
                                         var type=checkType(num);
                                         //oscarLog(document.getElementById('patient'+patientId+'all'));
                                         if(document.getElementById('patient'+patientId+'all')){
                                             //oscarLog('if');
                                             //case 1,patientName exists
                                         //check the type of doclab,
                                         //check if the type is present, if yes, increase by 1; if not, create and set to 1.

                                             if(type=='DOC'){
                                                 if(document.getElementById('patient'+patientId+'docs')){
                                                     increaseCount('pDocNum_'+patientId);
                                                     changed=true;
                                                 }else{
                                                     var newEle=createNewDocEle(patientId);
                                                     //oscarLog(document.getElementById('labdoc'+patientId+'showSublist'));
                                                     new Insertion.Bottom('labdoc'+patientId+'showSublist',newEle);
                                                     changed=true;
                                                 }
                                             }
                                             else if(type=='HL7'){
                                                 if(document.getElementById('patient'+patientId+'hl7s')){
                                                     increaseCount('pLabNum_'+patientId);
                                                     changed=true;
                                                 }else{
                                                     var newEle=createNewHL7Ele(patientId);
                                                     new Insertion.Bottom('labdoc'+patientId+'showSublist',newEle);
                                                     changed=true;
                                                 }
                                             }
                                             if(changed){
                                                 increaseCount('patientNumDocs'+patientId);
                                             }
                                         }else{
                                             //oscarLog('else');
                                             //case 2, patientname doesn't exists in nav bar at all
                                         //create patientname, check if labdoc is a lab or a doc.
                                         //create lab/doc nav
                                            var ele=createPatientDocLabEle(patientId,num);
                                            changed=true;
                                         }
                                         if(changed){//decrease Not,Assigned by 1
                                             decreaseCount('patientNumDocs-1');
                                             if(type=='DOC'){
                                                 decreaseCount('pDocNum_-1');
                                             }else if(type=='HL7'){
                                                 decreaseCount('pLabNum_-1');
                                             }
                                             return true;
                                         }
                                     }
                                 }
function createPatientDocLabEle(patientId,doclabid){
	var url=contextpath+"/dms/ManageDocument.do";
	var data='method=getDemoNameAjax&demo_no='+patientId;

    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
		    var json=jQuery.parseJSON(transport);
		    if(json!=null ){
			    var patientName=json.demoName;//get name from id
			    addPatientId(patientId);
			    addPatientIdName(patientId,patientName);
			    var e='<dt><img id="plus'+patientId+'" alt="plus" src="../images/plus.png" onclick="showhideSubCat(\'plus\',\''+patientId+'\');"/><img id="minus'+patientId+'" alt="minus" style="display:none;" src="../images/minus.png" onclick="showhideSubCat(\'minus\',\''+patientId+'\');"/>'+
			    '<a id="patient'+patientId+'all" href="javascript:void(0);"  onclick="resetCurrentFirstDocLab();showThisPatientDocs(\''+patientId+'\');un_bold(this);" title="'+patientName+'">'+patientName+' (<span id="patientNumDocs'+patientId+'">1</span>)</a>'+
			    '<dl id="labdoc'+patientId+'showSublist" style="display:none" >';
			    var type=checkType(doclabid);
			    var s;
			    if(type=='DOC'){
				    s=createNewDocEle(patientId);
			    }else if(type=='HL7'){
				    s=createNewHL7Ele(patientId);
			    }else{return '';}
			    e+=s;
			    e+='</dl></dt>';
                // Insert the html into the page as the last child of element.
                jQuery("#patientsdoclabs:last-child").append(e);
			    //new Insertion.Bottom('patientsdoclabs',e);
			    return e;
		    }
        }
    });

}


                            function createNewDocEle(patientId){
                                       var newEle='<dt><a id="patient'+patientId+'docs" href="javascript:void(0);" onclick="resetCurrentFirstDocLab();showSubType(\''+patientId+'\',\'DOC\');un_bold(this);" title="Documents">Documents(<span id="pDocNum_'+patientId+'">1</span>)</a></dt>';
                                       //oscarLog('newEle='+newEle);
                                       return newEle;
                                 }
                                function createNewHL7Ele(patientId){
                                       var newEle='<dt><a id="patient'+patientId+'hl7s" href="javascript:void(0);" onclick="resetCurrentFirstDocLab();showSubType(\''+patientId+'\',\'HL7\');un_bold(this);" title="HL7s">HL7s(<span id="pLabNum_'+patientId+'">1</span>)</a></dt>';
                                       //oscarLog('newEle='+newEle);
                                       return newEle;
                                 }
                              function   increaseCount(eleId){
                                    if(document.getElementById(eleId)){
                                         var n=document.getElementById(eleId).innerHTML;
                                         if(n.length>0){
                                             n=parseInt(n);
                                             n++;
                                             document.getElementById(eleId).innerHTML=n;
                                         }
                                     }
                                 }
                              function   decreaseCount(eleId){
                                    if(document.getElementById(eleId)){
                                         var n=document.getElementById(eleId).innerHTML;
                                         if(n.length>0){
                                             n=parseInt(n);
                                             if(n>0){
                                                 n--;
                                             }else{
                                                 n=0;
                                             }
                                             document.getElementById(eleId).innerHTML=n;
                                         }
                                     }
                                 }

                            function saveNext(docid){
                                updateDocument('forms_'+docid,true);

}

function  updateDocStatusInQueue(docid){//change status of queue document link row to I=inactive
    //console.log('in updateDocStatusInQueue, docid '+docid);
    var url="../dms/inboxManage.do"
    var data="docid="+docid+"&method=updateDocStatusInQueue";

	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (transport) {	},
		error: function(jqXHR, err, exception) {
			//alert("Error " + jqXHR.status + " " + err);
		}
	});

}
function updateDocument(eleId){
	if (!checkObservationDate(eleId)) {
		return false;
	}
	//save doc info
	var url="../dms/ManageDocument.do";
    var data= jQuery('#'+eleId).serialize();


    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
		    var json=jQuery.parseJSON(transport);
		    //console.log(json);
		    if(json!=null ){
			    patientId=json.patientId;
                var ar=eleId.split("_");
                var num=ar[1];
                num=num.replace(/\s/g,'');
                document.getElementById("saveSucessMsg_"+num).style.display = '';
                document.getElementById('saved'+num).value='true';
                document.getElementById('demofind'+num).value=patientId;
                document.getElementById('demofindName'+num).value=document.getElementById('autocompletedemo'+num).value;
                document.getElementById('assignedPId_'+num).textContent=document.getElementById('autocompletedemo'+num).value;
                document.getElementById("msgBtn_"+num).onclick = function() { popup(700,960, contextpath +'/oscarMessenger/SendDemoMessage.do?demographic_no='+patientId,'msg'); };
                // enable buttons that need a pid
	            jQuery('a').removeClass('disabled');
                document.getElementById('save'+num).removeAttribute('disabled');
	            //document.getElementById('saveNext'+num).removeAttribute('disabled');
	            document.getElementById('dropdown_'+num).removeAttribute('disabled');
	            document.getElementById('dropdown2_'+num).removeAttribute('disabled');
	            document.getElementById('msgBtn_'+num).removeAttribute('disabled');
	            document.getElementById('ticklerBtn_'+num).removeAttribute('disabled');
	            document.getElementById('recallBtn_'+num).removeAttribute('disabled');
	            document.getElementById('rxBtn_'+num).removeAttribute('disabled');
			    updateDocStatusInQueue(num);
			    var success= updateGlobalDataAndSideNav(num,patientId);
    			if(success){
				    success=updatePatientDocLabNav(num,patientId); /// PHC
				    if(success){
					    //disable demo input
					    document.getElementById('autocompletedemo'+num).disabled=true;
    					//console.log('updated by save');
    					//console.log(patientDocs);
    					//Effect.BlindUp('labdoc_'+num);
    					jQuery('#labdoc_'+num).hide('fade'); //jQueryUI
    					updateDocStatusInQueue(num);
    					updateSideNav(num,true);
    					removeDocFromQueue(num);
    				}
			    }
		    }
        }
    });


	return false;
}

function updateStatus(formid){//acknowledge Document
	var num=formid.split("_");
	var doclabid=num[1];
	if(doclabid){
		var demoId=document.getElementById('demofind'+doclabid).value;
		var saved=document.getElementById('saved'+doclabid).value;
		if(demoId=='-1'|| saved=='false'){
			alert('Document is not assigned and saved to a patient,please file it');
		}else{
			var url=contextpath+"/oscarMDS/UpdateStatus.do";
            var data= jQuery('#'+formid).serialize();

	        jQuery.ajax({
		        type: "POST",
		        url:  url,
		        data: data,
		        success: function (transport) {
				    if(doclabid){
                        // hide similar to Effect.Blindup()
					    jQuery('#labdoc_'+doclabid).hide('fade'); //jQueryUI if not loaded a simple hide will occur
					    updateDocStatusInQueue(doclabid);
                        removeDocFromQueue(doclabid);
				    }
            	},
		        error: function(jqXHR, err, exception) {
			        console.log(jqXHR.status);
		        }
	        });
		}
	}
}

function refileDoc(id) {
    var queueId=document.getElementById('queueList_'+id).options[document.getElementById('queueList_'+id).selectedIndex].value;
    var url=contextpath +"/dms/ManageDocument.do";
    var data='method=refileDocumentAjax&documentId='+id+"&queueId="+queueId;

    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
            fileDoc(id);
        }
    });
 }


function fileDoc(docId){
	if(docId){
		docId=docId.replace(/\s/,'');
		if(docId.length>0){
			var demoId=document.getElementById('demofind'+docId).value;
			var isFile=true;
			if(demoId=='-1'){
				isFile=confirm('Document is not assigned to any patient, do you still want to file it?');
			}
			if(isFile) {
				var type='DOC';
				if(type){
					var url='../oscarMDS/FileLabs.do';
					var data='method=fileLabAjax&flaggedLabId='+docId+'&labType='+type;

	                jQuery.ajax({
		                type: "POST",
		                url:  url,
		                data: data,
		                success: function (transport) {
						    jQuery('#labdoc_'+docId).hide('fade'); // jQueryUI dependency
						    updateDocLabData(docId,true);
						    removeDocFromQueue(docId);
                    	},
		                error: function(jqXHR, err, exception) {
			                console.log(jqXHR.status);
		                }
	                });
				}//if Type
			} //isFile
		} //if length>0
	}//if(docId)
}//fcn


                                       function forceFileDoc(docId){
                                           if(docId){
                                                docId=docId.replace(/\s/,'');
                                                if(docId.length>0){

	                                                var type='DOC';
	                                                if(type){
	                                                    var url='../oscarMDS/FileLabs.do';
	                                                   var data='method=fileLabAjax&flaggedLabId='+docId+'&labType='+type;
	                                                   new Ajax.Request(url, {method: 'post',parameters:data,onSuccess:function(transport){
	                                                           Effect.Fade('labdoc_'+docId);
	                                                           updateDocLabData(docId,true);
	                                                           removeDocFromQueue(doclabid);
	                                                   }});
	                                           }
	                                       	}
                                         }

                                       }
                                       function showPatientPreview(pid,providerNo,searchProviderNo,ackStatus){
                                           var labdocsArr=getLabDocFromPatientId(pid);
                                           var docs='';
                                           var labs='';
                                           for(var i=0;i<labdocsArr.length;i++){
                                                var labdoc=labdocsArr[i];
                                                labdoc=labdoc.replace(' ','');

                                                var type=checkType(labdoc);
                                                if(type=='DOC')
                                                    docs+=labdoc+",";
                                                else if(type=='HL7')
                                                    labs+=labdoc+",";
                                           }
                                           if( docs.lastIndexOf(",") == docs.length-1) {
                                        	   docs = docs.substring(0,docs.length-1);
                                           }
                                           if( labs.lastIndexOf(",") == labs.length-1) {
                                        	   labs = labs.substring(0,labs.length-1);
                                           }
                                           var url='../dms/inboxManage.do?';
                                           var data='method=previewPatientDocLab&demog='+pid+'&docs='+docs+'&labs='+labs+'&providerNo='+providerNo+'&searchProviderNo='+searchProviderNo+'&ackStatus='+ackStatus;
                                           url=url+data;
                                           var windowprops = "height=800,width=800,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=600,screenY=200,top=0,left=0";
                                           var w=window.open(url,"PreviewDocumentandLab",windowprops);
                                           if(w!=null)
                                               w.focus();
                                       }

                                       function showPageImg(docid,pn,cp){
                                                    if(docid&&pn&&cp){
                                                        var e=document.getElementById('docImg_'+docid);
                                                        var url=cp+'/dms/ManageDocument.do?method=viewDocPage&doc_no='+docid+'&curPage='+pn;
                                                        e.setAttribute('src',url);
                                                    }
                                                }

                                       function nextPage(docid,cp){
                                           var curPage=document.getElementById('curPage_'+docid).value;
                                           var totalPage=document.getElementById('totalPage_'+docid).value;
                                           curPage++;
                                           if(curPage>totalPage){
                                               curPage=totalPage;
                                               hideNext(docid);
                                               showPrev(docid);
                                           }
                                                  document.getElementById('curPage_'+docid).value=curPage;

                                                        showPageImg(docid,curPage,cp);
                                                        if(curPage>=totalPage){
                                                            hideNext(docid);
                                                            showPrev(docid);
                                                        } else{
                                                            showNext(docid);
                                                            showPrev(docid);
                                                        }
                                                }
                                                function prevPage(docid,cp){
                                                     var curPage=document.getElementById('curPage_'+docid).value;
                                                    curPage--;
                                                    if(curPage<1){
                                                        curPage=1;
                                                        hidePrev(docid);
                                                        showNext(docid);
                                                    }
                                                    document.getElementById('curPage_'+docid).value=curPage;
                                                        showPageImg(docid,curPage,cp);
                                                       if(curPage==1){
                                                           hidePrev(docid);
                                                           showNext(docid);
                                                        }else{
                                                            showPrev(docid);
                                                            showNext(docid);
                                                        }

                                                }
                                                function firstPage(docid,cp){
                                                   document.getElementById('curPage_'+docid).value=1;
                                                    showPageImg(docid,1,cp);
                                                    hidePrev(docid);
                                                    showNext(docid);
                                                }
                                                function lastPage(docid,cp){
                                                    var totalPage=document.getElementById('totalPage_'+docid).value;

                                                    document.getElementById('curPage_'+docid).value=totalPage;
                                                    showPageImg(docid,totalPage,cp);
                                                    hideNext(docid);
                                                    showPrev(docid);
                                                }
                                                function hidePrev(docid){
                                                    //disable previous link
                                                    document.getElementById("prevP_"+docid).setStyle({display:'none'});
                                                    document.getElementById("firstP_"+docid).setStyle({display:'none'});
                                                }
                                                function hideNext(docid){
                                                    //disable next link
                                                    document.getElementById("nextP_"+docid).setStyle({display:'none'});
                                                    document.getElementById("lastP_"+docid).setStyle({display:'none'});
                                                }
                                                function showPrev(docid){
                                                    //disable previous link
                                                    document.getElementById("prevP_"+docid).setStyle({display:'inline'});
                                                    document.getElementById("firstP_"+docid).setStyle({display:'inline'});
                                                }
                                                function showNext(docid){

                                                    //disable next link
                                                    document.getElementById("nextP_"+docid).setStyle({display:'inline'});
                                                    document.getElementById("lastP_"+docid).setStyle({display:'inline'});
                                                }
</script>

    </head>
    <body>
    <%
    HashMap queueIdNames=(HashMap)request.getAttribute("queueIdNames");//each queue id has a corresponding name
    HashMap queueDocNos=(HashMap)request.getAttribute("queueDocNos");//one queue id is linked to a list of docs
    String providerNo=(String)request.getAttribute("providerNo");
    String searchProviderNo=(String)request.getAttribute("searchProviderNo");
    Set keys=queueDocNos.keySet();
    Iterator itr=keys.iterator();
    String patientIdNamesStr=(String)request.getAttribute("patientIdNamesStr");
    HashMap docStatus=(HashMap)request.getAttribute("docStatus");
    String patientIdStr =(String)request.getAttribute("patientIdStr");
    HashMap typeDocLab =(HashMap)request.getAttribute("typeDocLab");
    HashMap docType=(HashMap)request.getAttribute("docType");
    HashMap patientDocs=(HashMap)request.getAttribute("patientDocs");
    List<String> normals=(List<String>)request.getAttribute("normals");
    List<String> abnormals=(List<String>)request.getAttribute("abnormals");

%>

        <table id="pendingDocs" style="width:100%;">
             <tr class="MainTableTopRow">
                <td class="MainTableTopRowRightColumn" colspan="2">
                 <table style="width:100%; background-color:gainsboro;">
                     <tr >
                         <td style="text-align:center; vertical-align:center;" colspan="2" class="Nav"><span style="font-weight:bold;"><bean:message key="inboxmanager.documentsInQueues"/></span></td>
                     </tr>
                        <tr>
                            <td style="text-align:left; vertical-align:center;" >
                                <input type="hidden" name="providerNo" value="<%= providerNo %>">
                                <input type="hidden" name="searchProviderNo" value="<%= searchProviderNo %>">
                                <%= (request.getParameter("lname") == null ? "" : "<input type=\"hidden\" name=\"lname\" value=\""+request.getParameter("lname")+"\">") %>
                                <%= (request.getParameter("fname") == null ? "" : "<input type=\"hidden\" name=\"fname\" value=\""+request.getParameter("fname")+"\">") %>
                                <%= (request.getParameter("hnum") == null ? "" : "<input type=\"hidden\" name=\"hnum\" value=\""+request.getParameter("hnum")+"\">") %>

                                <input type="hidden" name="selectedProviders">

                                <input type="button" class="btn" onclick="window.close();" value="<bean:message key="oscarMDS.index.btnClose"/>">

                            </td>

                            <td style="text-align:right; vertical-align:center; width:30%">
                                <oscar:help keywords="inbox queue" key="app.top1"/>
                                | <a href="javascript:popupStart(300,400,'../oscarEncounter/About.jsp')"  ><bean:message key="global.about"/></a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <th class="Cell" style="text-align:left; vertical-align:bottom; white-space: nowrap;">Queues</th>
                <th class="Cell" style="text-align:left; vertical-align:bottom; white-space: nowrap;">Documents</th>
            </tr>
            <tr >
                <td id="queueNames" style="vertical-align: top; width:10%">
                    <%
                    while(itr.hasNext()){
                        Integer qId=(Integer)itr.next();
                        String name=(String)queueIdNames.get(qId);
                        List dos=(List)queueDocNos.get(qId);
                        Integer numberOfDocs=dos.size();
%>
<a href="javascript:void(0);" onclick="resetCurrentFirstDocLab();showDocInQueue('<%=qId%>')"><%=name%>&nbsp;(<span id="docNo_<%=qId%>"><%=numberOfDocs%></span>)</a><br>
                    <%}%>

                </td>

                <td style="vertical-align: top; width:90%" id="docs"></td>
            </tr>
        </table>
                    <script>
                            var current_first_doclab=0;
                           var typeDocLab=initTypeDocLab('<%=typeDocLab%>');   //{DOC=[357, 317, 316], HL7=[38, 33, 30, 28]}
                           var docType=initDocType('<%=docType%>');   //{357=DOC, 38=HL7, 317=DOC, 316=DOC, 33=HL7, 30=HL7, 28=HL7}
                           var patientDocs=initPatientDocs('<%=patientDocs%>');//{2=[316, 30, 28], 1=[33], -1=[357, 317, 38]}
                           var patientIdNames=initPatientIdNames('<%=StringEscapeUtils.escapeJavaScript(patientIdNamesStr)%>');//;2=TEST2, PATIENT2;1=Zrrr, Srrr;-1=Not, Assigned
                           var docStatus=initDocStatus('<%=docStatus%>');//{357=A, 38=N, 317=A, 316=A, 33=N, 30=N, 28=N}
                           var normals=initNormals('<%=normals%>');//[357, 317, 316, 38, 33, 30, 28]
                           var abnormals=initAbnormals('<%=abnormals%>');//[123,567]
                           var patientIds=initPatientIds('<%=patientIdStr%>');
                        var queueDocNos=initHashtblWithList('<%=queueDocNos%>');
                        var providerNo='<%=providerNo%>';

                        var searchProviderNo='<%=searchProviderNo%>';
 /*console.log(typeDocLab);
 console.log(docType);
 console.log(patientDocs);
 console.log(patientIdNames);
 console.log(docStatus);
 console.log(normals);
 console.log(abnormals);
 console.log(patientIds);
 console.log(queueDocNos);
 console.log(providerNo);
 console.log(searchProviderNo);*/
                           var types=['DOC'];

                        var contextpath='<%=request.getContextPath()%>';
//Event.observe(window,'scroll',function(){//check for scrolling
 //   bufferAndShow();
//});
window.addEventListener('scroll', function(evt) {
    bufferAndShow();
});



</script>
    </body>
</html:html>
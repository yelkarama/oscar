/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.managers;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.util.ArrayList;
//import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.ConsultDocsDao;
import org.oscarehr.common.dao.ConsultRequestDao;
import org.oscarehr.common.dao.ConsultResponseDao;
import org.oscarehr.common.dao.ConsultResponseDocDao;
import org.oscarehr.common.dao.ConsultationRequestArchiveDao;
import org.oscarehr.common.dao.ConsultationRequestExtArchiveDao;
import org.oscarehr.common.dao.ConsultationRequestExtDao;
import org.oscarehr.common.dao.ConsultationServiceDao;
import org.oscarehr.common.dao.DocumentDao.DocumentType;
import org.oscarehr.common.dao.DocumentDao.Module;
import org.oscarehr.common.dao.EReferAttachmentDao;
import org.oscarehr.common.dao.Hl7TextInfoDao;
import org.oscarehr.common.dao.ProfessionalSpecialistDao;
import org.oscarehr.common.dao.PropertyDao;
import org.oscarehr.common.hl7.v2.oscar_to_oscar.OruR01;
import org.oscarehr.common.hl7.v2.oscar_to_oscar.OruR01.ObservationData;
import org.oscarehr.common.hl7.v2.oscar_to_oscar.RefI12;
import org.oscarehr.common.hl7.v2.oscar_to_oscar.SendingUtils;
import org.oscarehr.common.model.AbstractModel;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.ConsultDocs;
import org.oscarehr.common.model.ConsultResponseDoc;
import org.oscarehr.common.model.ConsultationRequest;
import org.oscarehr.common.model.ConsultationRequestArchive;
import org.oscarehr.common.model.ConsultationRequestExt;
import org.oscarehr.common.model.ConsultationRequestExtArchive;
import org.oscarehr.common.model.ConsultationResponse;
import org.oscarehr.common.model.ConsultationServices;
import org.oscarehr.common.model.CtlDocument;
import org.oscarehr.common.model.CtlDocumentPK;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Document;
import org.oscarehr.common.model.EReferAttachmentData;
import org.oscarehr.common.model.Hl7TextInfo;
import org.oscarehr.common.model.Hl7TextMessage;
import org.oscarehr.common.model.EReferAttachment;
import org.oscarehr.common.model.ProfessionalSpecialist;
import org.oscarehr.common.model.Property;
import org.oscarehr.common.model.Provider;
import org.oscarehr.consultations.ConsultationRequestSearchFilter;
import org.oscarehr.consultations.ConsultationRequestSearchFilter.SORTDIR;
import org.oscarehr.consultations.ConsultationResponseSearchFilter;
import org.oscarehr.hospitalReportManager.HRMPDFCreator;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.ws.rest.conversion.OtnEconsultConverter;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.WKHtmlToPdfUtils;
import org.oscarehr.ws.rest.to.model.ConsultationAttachment;
import org.oscarehr.ws.rest.to.model.ConsultationRequestSearchResult;
import org.oscarehr.ws.rest.to.model.ConsultationResponseSearchResult;
import org.oscarehr.ws.rest.to.model.OtnEconsult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lowagie.text.DocumentException;

import ca.uhn.hl7v2.HL7Exception;
import ca.uhn.hl7v2.model.v26.message.ORU_R01;
import ca.uhn.hl7v2.model.v26.message.REF_I12;
import oscar.OscarProperties;
import oscar.dms.EDoc;
import oscar.dms.EDocUtil;
import oscar.eform.actions.PrintAction;
import oscar.log.LogAction;
import oscar.oscarLab.ca.all.pageUtil.LabPDFCreator;
import oscar.oscarLab.ca.all.pageUtil.OLISLabPDFCreator;
import oscar.oscarLab.ca.on.CommonLabResultData;
import oscar.oscarLab.ca.on.LabResultData;

@Service
public class ConsultationManager {

	@Autowired
	ConsultRequestDao consultationRequestDao;
	@Autowired
	ConsultResponseDao consultationResponseDao;
	@Autowired
	ConsultationServiceDao serviceDao;
	@Autowired
	ProfessionalSpecialistDao professionalSpecialistDao;
	@Autowired
	ConsultDocsDao requestDocDao;
	@Autowired
	ConsultResponseDocDao responseDocDao;
	@Autowired
	PropertyDao propertyDao;
	@Autowired
	Hl7TextInfoDao hl7TextInfoDao;
	@Autowired
	ClinicDAO clinicDao;
	@Autowired
	DemographicManager demographicManager;
	@Autowired
	SecurityInfoManager securityInfoManager;
	@Autowired
	ConsultationRequestExtDao consultationRequestExtDao;
	@Autowired
	ConsultationRequestExtArchiveDao consultationRequestExtArchiveDao;
	@Autowired
	ConsultationRequestArchiveDao consultationRequestArchiveDao;
	@Autowired
	DocumentManager documentManager;
	@Autowired
	private EReferAttachmentDao eReferAttachmentDao;
	@Autowired
	private LabManager labManager;

	private final Logger logger = MiscUtils.getLogger();
	
	public final String CON_REQUEST_ENABLED = "consultRequestEnabled";
	public final String CON_RESPONSE_ENABLED = "consultResponseEnabled";
	public final String ENABLED_YES = "Y";
	
	public List<ConsultationRequestSearchResult> search(LoggedInInfo loggedInInfo, ConsultationRequestSearchFilter filter) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		List<ConsultationRequestSearchResult> r = new  ArrayList<ConsultationRequestSearchResult>();
		List<Object[]> result = consultationRequestDao.search(filter);
		
		for(Object[] items:result) {
			ConsultationRequest consultRequest = (ConsultationRequest)items[0];
			LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.searchRequest", "id="+consultRequest.getId());
			r.add(convertToRequestSearchResult(items));
		}
		return r;
	}
	
	public List<ConsultationResponseSearchResult> search(LoggedInInfo loggedInInfo, ConsultationResponseSearchFilter filter) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		List<ConsultationResponseSearchResult> r = new  ArrayList<ConsultationResponseSearchResult>();
		List<Object[]> result = consultationResponseDao.search(filter);
		
		for(Object[] items:result) {
			ConsultationResponse consultResponse = (ConsultationResponse)items[0];
			LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.searchResponse", "id="+consultResponse.getId());
			r.add(convertToResponseSearchResult(items));
		}
		return r;
	}
	
	public int getConsultationCount(ConsultationRequestSearchFilter filter) {
		return consultationRequestDao.getConsultationCount2(filter);
	}
	
	public int getConsultationCount(ConsultationResponseSearchFilter filter) {
		return consultationResponseDao.getConsultationCount(filter);
	}
	
	public boolean hasOutstandingConsultations(LoggedInInfo loggedInInfo, Integer demographicNo) {
		//Outstanding consultations = Incomplete consultation requests > 1 month
		ConsultationRequestSearchFilter filter = new ConsultationRequestSearchFilter();
		filter.setDemographicNo(demographicNo);
		filter.setNumToReturn(100);
		filter.setSortDir(SORTDIR.asc);
		
		List<ConsultationRequestSearchResult> results = search(loggedInInfo, filter);
		boolean outstanding = false;
		for (ConsultationRequestSearchResult result : results) {
			if (result.getReferralDate()!=null) {
				Calendar cal = Calendar.getInstance();
				cal.setTime(result.getReferralDate());
				cal.roll(Calendar.MONTH, true);
				if (new Date().after(cal.getTime())) {
					outstanding = true; break;
				}
			}
		}
		return outstanding;
	}
	
	public ConsultationRequest getRequest(LoggedInInfo loggedInInfo, Integer id) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		ConsultationRequest request = consultationRequestDao.find(id);
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.getRequest", "id="+request.getId());
		
		return request;
	}
	
	public ConsultationResponse getResponse(LoggedInInfo loggedInInfo, Integer id) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		ConsultationResponse response = consultationResponseDao.find(id);
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.getResponse", "id="+response.getId());
		
		return response;
	}
	
	public List<ConsultationServices> getConsultationServices() {
		List<ConsultationServices> services = serviceDao.findActive();
		for (ConsultationServices service : services) {
			if (service.getServiceDesc().equals(serviceDao.REFERRING_DOCTOR)) {
				services.remove(service);
				break;
			}
		}
		return services;
	}
	
	public ConsultationServices getConsultationService(Integer id) {
		return serviceDao.find(id);
	}
	
	public List<ProfessionalSpecialist> getReferringDoctorList() {
		ConsultationServices service = serviceDao.findReferringDoctorService(serviceDao.ACTIVE_ONLY);
		return (service==null) ? null : service.getSpecialists();
	}
	
	public ProfessionalSpecialist getProfessionalSpecialist(Integer id) {
		return professionalSpecialistDao.find(id);
	}
	
	public void saveConsultationRequest(LoggedInInfo loggedInInfo, ConsultationRequest request) {
		if (request.getId()==null) { //new consultation request
			checkPrivilege(loggedInInfo, SecurityInfoManager.WRITE);
			
			ProfessionalSpecialist specialist = request.getProfessionalSpecialist();
			request.setProfessionalSpecialist(null);
			consultationRequestDao.persist(request);
			
			request.setProfessionalSpecialist(specialist);
			consultationRequestDao.merge(request);
			
			// Batch saves the provided extras if any exist
			List<ConsultationRequestExt> extras = request.getExtras();
			if (!extras.isEmpty()) {
				List<AbstractModel<?>> toSave = new ArrayList<>();
				Date dateCreated = new Date();
				for (ConsultationRequestExt extra : extras) {
					extra.setRequestId(request.getId());
					extra.setDateCreated(dateCreated);
					toSave.add(extra);
				}
				consultationRequestExtDao.batchPersist(toSave);
			}
			
			
		} else {
			checkPrivilege(loggedInInfo, SecurityInfoManager.UPDATE);

			archiveConsultationRequest(request.getId());
			
			consultationRequestDao.merge(request);

			if (!request.getExtras().isEmpty()) {
				saveOrUpdateExts(request.getId(), request.getExtras());
				// Sets the request's extras to all current extras with the updated information
				List<ConsultationRequestExt> extras = consultationRequestExtDao.getConsultationRequestExts(request.getId());
				request.setExtras(extras);
			}
		}
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.saveConsultationRequest", "id="+request.getId());
	}
	
	public void saveConsultationResponse(LoggedInInfo loggedInInfo, ConsultationResponse response) {
		if (response.getId()==null) { //new consultation response
			checkPrivilege(loggedInInfo, SecurityInfoManager.WRITE);
			
			consultationResponseDao.persist(response);
		} else {
			checkPrivilege(loggedInInfo, SecurityInfoManager.UPDATE);
			
			consultationResponseDao.merge(response);
		}
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.saveConsultationResponse", "id="+response.getId());
	}
	
	public List<ConsultDocs> getConsultRequestDocs(LoggedInInfo loggedInInfo, Integer requestId) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		List<ConsultDocs> docs = requestDocDao.findByRequestId(requestId);
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.getConsultRequestDocs", "consult id="+requestId);
		
		return docs;
	}
	
	public List<ConsultResponseDoc> getConsultResponseDocs(LoggedInInfo loggedInInfo, Integer responseId) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		List<ConsultResponseDoc> docs = responseDocDao.findByResponseId(responseId);
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.getConsultResponseDocs", "consult id="+responseId);
		
		return docs;
	}
	
	public void saveConsultRequestDoc(LoggedInInfo loggedInInfo, ConsultDocs doc) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.UPDATE);
		
		if (doc.getId()==null) { //new consultation attachment
			requestDocDao.persist(doc);
		} else {
			requestDocDao.merge(doc); //only used for setting doc "deleted"
		}
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.saveConsultRequestDoc", "id="+doc.getId());
	}
	
	public void saveConsultResponseDoc(LoggedInInfo loggedInInfo, ConsultResponseDoc doc) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.UPDATE);
		
		if (doc.getId()==null) { //new consultation attachment
			responseDocDao.persist(doc);
		} else {
			responseDocDao.merge(doc); //only used for setting doc "deleted"
		}
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.saveConsultResponseDoc", "id="+doc.getId());
	}
	
	public void enableConsultRequestResponse(boolean conRequest, boolean conResponse) {
		Property consultRequestEnabled = new Property(CON_REQUEST_ENABLED);
		Property consultResponseEnabled = new Property(CON_RESPONSE_ENABLED);
		
		List<Property> results = propertyDao.findByName(CON_REQUEST_ENABLED);
		if (results.size()>0) consultRequestEnabled = results.get(0);
		results = propertyDao.findByName(CON_RESPONSE_ENABLED);
		if (results.size()>0) consultResponseEnabled = results.get(0);
		
		consultRequestEnabled.setValue(conRequest?ENABLED_YES:null);
		consultResponseEnabled.setValue(conResponse?ENABLED_YES:null);
		
		propertyDao.merge(consultRequestEnabled);
		propertyDao.merge(consultResponseEnabled);
		
		ConsultationServices referringDocService = serviceDao.findReferringDoctorService(serviceDao.WITH_INACTIVE);
		if (referringDocService==null) referringDocService = new ConsultationServices(serviceDao.REFERRING_DOCTOR);
		if (conResponse) referringDocService.setActive(serviceDao.ACTIVE);
		else referringDocService.setActive(serviceDao.INACTIVE);
		
		serviceDao.merge(referringDocService);
	}
	
	public boolean isConsultRequestEnabled() {
		List<Property> results = propertyDao.findByName(CON_REQUEST_ENABLED);
		if (results.size()>0 && ENABLED_YES.equals(results.get(0).getValue())) return true;
		return false;
	}
	
	public boolean isConsultResponseEnabled() {
		List<Property> results = propertyDao.findByName(CON_RESPONSE_ENABLED);
		if (results.size()>0 && ENABLED_YES.equals(results.get(0).getValue())) return true;
		return false;
	}

	/*
	 * Send consultation request electronically
	 * Copied and modified from
	 * 	oscar/oscarEncounter/oscarConsultationRequest/pageUtil/EctConsultationFormRequestAction.java
	 */
	public void doHl7Send(LoggedInInfo loggedInInfo, Integer consultationRequestId) throws InvalidKeyException, SignatureException, NoSuchAlgorithmException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException, InvalidKeySpecException, IOException, HL7Exception, ServletException, DocumentException {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		ConsultationRequest consultationRequest=consultationRequestDao.find(consultationRequestId);
		ProfessionalSpecialist professionalSpecialist=professionalSpecialistDao.find(consultationRequest.getSpecialistId());
		Clinic clinic=clinicDao.getClinic();
		
		// set status now so the remote version shows this status
		consultationRequest.setStatus("2");

		REF_I12 refI12=RefI12.makeRefI12(clinic, consultationRequest);
		SendingUtils.send(loggedInInfo, refI12, professionalSpecialist);
		
		// save after the sending just in case the sending fails.
		consultationRequestDao.merge(consultationRequest);
		
		//--- send attachments ---
		Provider sendingProvider=loggedInInfo.getLoggedInProvider();
		Demographic demographic=demographicManager.getDemographic(loggedInInfo, consultationRequest.getDemographicId());

		//--- process all documents ---
		ArrayList<EDoc> attachments=EDocUtil.listDocs(loggedInInfo, demographic.getDemographicNo().toString(), consultationRequest.getId().toString(), EDocUtil.ATTACHED);
		for (EDoc attachment : attachments)
		{
			ObservationData observationData=new ObservationData();
			observationData.subject=attachment.getDescription();
			observationData.textMessage="Attachment for consultation : "+consultationRequestId;
			observationData.binaryDataFileName=attachment.getFileName();
			observationData.binaryData=attachment.getFileBytes();

			ORU_R01 hl7Message=OruR01.makeOruR01(clinic, demographic, observationData, sendingProvider, professionalSpecialist);		
			SendingUtils.send(loggedInInfo, hl7Message, professionalSpecialist);			
		}
		
		//--- process all labs ---
		CommonLabResultData labData = new CommonLabResultData();
		ArrayList<LabResultData> labs = labData.populateLabResultsData(loggedInInfo, demographic.getDemographicNo().toString(), consultationRequest.getId().toString(), CommonLabResultData.ATTACHED);
		for (LabResultData attachment : labs)
		{
			byte[] dataBytes=LabPDFCreator.getPdfBytes(attachment.getSegmentID(), sendingProvider.getProviderNo());
			Hl7TextInfo hl7TextInfo=hl7TextInfoDao.findLabId(Integer.parseInt(attachment.getSegmentID()));
			
			ObservationData observationData=new ObservationData();
			observationData.subject=hl7TextInfo.getDiscipline();
			observationData.textMessage="Attachment for consultation : "+consultationRequestId;
			observationData.binaryDataFileName=hl7TextInfo.getDiscipline()+".pdf";
			observationData.binaryData=dataBytes;

			
			ORU_R01 hl7Message=OruR01.makeOruR01(clinic, demographic, observationData, sendingProvider, professionalSpecialist);		
			int statusCode=SendingUtils.send(loggedInInfo, hl7Message, professionalSpecialist);
			if (HttpServletResponse.SC_OK!=statusCode) throw(new ServletException("Error, received status code:"+statusCode));
		}
	}
	
	/**
	 * Import a PDF formatted OTN eConsult.
	 * @throws Exception 
	 */
	public void importEconsult(LoggedInInfo loggedInInfo, OtnEconsult otnEconsult) throws Exception {
		checkPrivilege(loggedInInfo, SecurityInfoManager.WRITE);
		
		// convert to an Oscar Document
		OtnEconsultConverter otnEconsultConverter = new OtnEconsultConverter();
		Document document = otnEconsultConverter.getAsDomainObject(loggedInInfo, otnEconsult);
		CtlDocumentPK ctlDocumentPk = new CtlDocumentPK(Module.DEMOGRAPHIC.getName(), otnEconsult.getDemographicNo(), null);
		CtlDocument ctlDocument = new CtlDocument();
		ctlDocument.setStatus("A");
		ctlDocument.setId(ctlDocumentPk);
		
		// save the document
		document = documentManager.addDocument(loggedInInfo, document, ctlDocument);
		
		if(document == null)
		{		
			throw new Exception("Unknown exception during document save");
		}
		
		LogAction.addLogSynchronous(loggedInInfo, "ConsultationManager.importEconsult", "eConsult saved for demographic " + otnEconsult.getDemographicNo());
		
	}
	
	public List<Document> getEconsultDocuments(LoggedInInfo loggedInInfo, int demographicNo) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		return documentManager.getDemographicDocumentsByDocumentType(loggedInInfo, demographicNo, DocumentType.ECONSULT);
	}

	/**
	 * Gets attachments for use on an eReferral for the provided demographic number. It only gets the oldest prepped attachments within the past hour.
	 * @param loggedInInfo The current user's logged in info
	 * @param request The HttpRequest for printing any eforms
	 * @param demographicNo The demographic number to get the attachments for 
	 * @return List of ConsultationAttachments containing the file name and data and the attachment id and type, 
	 * @throws IOException Thrown if an error occurs with OutputStreams or when reading and printing files
	 * @throws DocumentException Thrown if a lab cannot be printed
	 * @throws RuntimeException Thrown if a lab does not have a matching Hl7TextMessage record or the content type is null/empty
	 */
	public List<ConsultationAttachment> getEReferAttachments(LoggedInInfo loggedInInfo, HttpServletRequest request, Integer demographicNo) throws Exception {
		List<ConsultationAttachment> attachments = new ArrayList<>();
		
		EReferAttachment eReferAttachment = eReferAttachmentDao.getRecentByDemographic(demographicNo);
		
		if (eReferAttachment != null) {
			StringBuilder data = new StringBuilder("Retrieved:");
			for (EReferAttachmentData attachmentData :  eReferAttachment.getAttachments()) {
				try {
						ConsultationAttachment attachment = null;
						switch (attachmentData.getLabType()) {
							case ConsultDocs.DOCTYPE_DOC:
								attachment = getDocumentAttachment(loggedInInfo, attachmentData.getLabId());
								break;

							case ConsultDocs.DOCTYPE_LAB:
								attachment = getLabAttachment(loggedInInfo, attachmentData.getLabId());
								break;

							case ConsultDocs.DOCTYPE_HRM:
								attachment = getHrmAttachment(loggedInInfo, attachmentData.getLabId());
								break;

							case ConsultDocs.DOCTYPE_EFORM:
								attachment = getEformAttachment(loggedInInfo, request, attachmentData.getLabId());
								break;

							/*case ConsultDocs.DOCTYPE_FORMPERINATAL:
								attachment = getPerinatalAttachment(loggedInInfo, attachmentData.getLabId(), eReferAttachment.getDemographicNo());
								break;*/
								
							default:
								throw new RuntimeException("Attachment type " + attachmentData.getLabType() + " does not match a printable type");
						}

						attachments.add(attachment);
						data.append("\n").append(attachment.getAttachmentType()).append(attachment.getId());
				} catch (Exception e) {
					logger.error("Attachment " + attachmentData.getLabType() + " " + attachmentData.getLabId() + " encountered an error while generating the file data", e);
					throw e;
				}
			}
			// Archives the retrieved attachments so they can't be retrieved again
			eReferAttachment.setArchived(true);
			eReferAttachmentDao.merge(eReferAttachment);
			
			LogAction.addLog(loggedInInfo, "Retrieved and archived eRefer attachments", "eReferAttachment id", eReferAttachment.getId().toString(), demographicNo.toString(), data.toString());
		}
		
		return attachments;
	}

	/**
	 * Gets a document's file data and file name for transfer
	 * @param loggedInInfo The logged in info of the current user
	 * @param id The id of the document to get the file data for
	 * @return ConsultationAttachment with the document's file name and file data in a byte array
	 * @throws IOException if the document's file data cannot be read
	 */
	private ConsultationAttachment getDocumentAttachment(LoggedInInfo loggedInInfo, Integer id) throws IOException, RuntimeException {
		ConsultationAttachment attachment;
		
		Document document = documentManager.getDocument(loggedInInfo, id);
		File file = new File(OscarProperties.getInstance().getProperty("DOCUMENT_DIR") + File.separator +  document.getDocfilename());
		
		attachment = new ConsultationAttachment(id, ConsultDocs.DOCTYPE_DOC, file.getName(), Files.readAllBytes(file.toPath()));
		
		return attachment;
	}

	/**
	 * Gets printed file data for the given lab id
	 * @param loggedInInfo The logged in info of the current user
	 * @param id The id of the lab to print and retrieve the data of
	 * @return ConsultationAttachment containing a file name and the printed file data
	 * @throws IOException Thrown if a temporary file cannot be created for non OLIS labs, the ByteArrayOutputStream or the FileOutputStream encounters an issue, or if an error occurs during print 
	 * @throws DocumentException Thrown by itext if an error occurs during print
	 * @throws RuntimeException Thrown if an Hl7TextMessage record doesn't exist or it doesn't have a message type
	 */
	private ConsultationAttachment getLabAttachment(LoggedInInfo loggedInInfo, Integer id) throws IOException, DocumentException {
		ConsultationAttachment attachment;
		Hl7TextMessage hl7TextMessage = labManager.getHl7Message(loggedInInfo, id);
		
		try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
			//Checks if the lab is OLIS
			if (hl7TextMessage.getType().equals("OLIS_HL7")) {
				//If the lab is OLIS, use the OLISLabPDFCreator to print the lab
				OLISLabPDFCreator olisLabPdfCreator = new OLISLabPDFCreator(baos, id.toString(), loggedInInfo.getLoggedInProvider());
				olisLabPdfCreator.printPdf();
			} else {
				File tempPdf = File.createTempFile(String.format("%03d", id), "pdf");
				try (FileOutputStream fos = new FileOutputStream(tempPdf)) {
					//If it isn't an OLIS lab, use the normal LabPDFCreator to print
					LabPDFCreator pdf = new LabPDFCreator(fos, id.toString(), loggedInInfo.getLoggedInProviderNo());
					pdf.printPdf();
					pdf.addEmbeddedDocuments(tempPdf, baos);
				}
			}
			
			String fileName = String.format("Lab_%03d.pdf", id);
			attachment = new ConsultationAttachment(id, ConsultDocs.DOCTYPE_LAB, fileName, baos.toByteArray());
		}
		
		return attachment;
	}

	/**
	 * Creates a ConsultationAttachment object containing the data for a printed HRM record
	 * @param loggedInInfo The current user's logged in info
	 * @param id The id of the HRM record to print
	 * @return ConsultationAttachment with the filename 
	 * @throws IOException Thrown if an error is encountered when printing the HRM
	 */
	private ConsultationAttachment getHrmAttachment(LoggedInInfo loggedInInfo, Integer id) throws IOException {
		ConsultationAttachment attachment;
		
		try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
			HRMPDFCreator hrmPdfCreator = new HRMPDFCreator(baos, id.toString(), loggedInInfo);
			hrmPdfCreator.printPdf();

			// Generates the filename and ConsultationAttachment
			String fileName = String.format("HRM_%03d.pdf", id);
			attachment = new ConsultationAttachment(id, ConsultDocs.DOCTYPE_HRM, fileName, baos.toByteArray());
		}
		
		return attachment;
	}

	/**
	 * Creates a ConsultationAttachment object containing the data of a printed eform relating to the given id 
	 * @param loggedInInfo The logged in info of the current user
	 * @param request The request object
	 * @param id The id of the eform to print
	 * @return ConsultationAttachment containing the eform's filename and file data in the form of a byte array
	 * @throws IOException Thrown if WKHtmlToPdf encounters an error while printing the eform
	 */
	private ConsultationAttachment getEformAttachment(LoggedInInfo loggedInInfo, HttpServletRequest request, Integer id) throws IOException {
		ConsultationAttachment attachment;
		
		String localUri = PrintAction.getEformRequestUrl(request);
		byte[] fileBytes = WKHtmlToPdfUtils.convertToPdf(localUri + id);

		// Generates the filename and ConsultationAttachment object
		String fileName = String.format("Eform_%03d.pdf", id);
		attachment = new ConsultationAttachment(id, ConsultDocs.DOCTYPE_EFORM, fileName, fileBytes);

		return attachment;
	}

	/*
	 * Creates a ConsultationAttachment object with the file data of a printed perinatal form
	 * @param loggedInInfo The current user's logged in info
	 * @param id The id of the perinatal form that will be printed
	 * @param demographicNo The demographic number the form is being printed for
	 * @return Generated ConsultationAttachment with a file name and byte array containing the data
	 * @throws IOException Thrown if an error occurs while printing the perinatal form
	 */
	/*private ConsultationAttachment getPerinatalAttachment(LoggedInInfo loggedInInfo, Integer id, Integer demographicNo) throws IOException {
		ConsultationAttachment attachment;
		
		try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
			FrmONPerinatalAction frmONPerinatalAction = new FrmONPerinatalAction();
			List<Integer> pagesToPrint = Arrays.asList(1, 2, 3, 4, 5);

			frmONPerinatalAction.printPdf(baos, loggedInInfo, demographicNo, id, pagesToPrint);
			
			// Generates the filename and attachment object
			String fileName = String.format("Perinatal_%03d.pdf", id);
			attachment = new ConsultationAttachment(id, ConsultDocs.DOCTYPE_FORMPERINATAL, fileName, baos.toByteArray());
		}
		
		return attachment;
	}*/
	
	private ConsultationRequestSearchResult convertToRequestSearchResult(Object[] items) {
		ConsultationRequestSearchResult result = new ConsultationRequestSearchResult();
		
		ConsultationRequest consultRequest = (ConsultationRequest)items[0];
		ProfessionalSpecialist professionalSpecialist = (ProfessionalSpecialist)items[1];
		ConsultationServices consultationServices = (ConsultationServices)items[2];
		Demographic demographic = (Demographic)items[3];
		Provider provider = (Provider)items[4];
		
		
		result.setAppointmentDate(joinDateAndTime(consultRequest.getAppointmentDate(),consultRequest.getAppointmentTime()));
		result.setConsultant(professionalSpecialist);
		result.setDemographic(demographic);
		result.setId(consultRequest.getId());
		result.setLastFollowUp(consultRequest.getFollowUpDate());
		result.setMrp(provider);
		result.setReferralDate(consultRequest.getReferralDate());
		result.setServiceName(consultationServices.getServiceDesc());
		result.setStatus(consultRequest.getStatus());
		result.setUrgency(consultRequest.getUrgency());

		if(consultRequest.getSendTo() != null && !consultRequest.getSendTo().isEmpty() && !consultRequest.getSendTo().equals("-1")) {
			result.setTeamName(consultRequest.getSendTo());	
		}
		
		return result;
	}
	
	private ConsultationResponseSearchResult convertToResponseSearchResult(Object[] items) {
		ConsultationResponseSearchResult result = new ConsultationResponseSearchResult();
		
		ConsultationResponse consultResponse = (ConsultationResponse)items[0];
		ProfessionalSpecialist professionalSpecialist = (ProfessionalSpecialist)items[1];
		Demographic demographic = (Demographic)items[2];
		Provider provider = (Provider)items[3];
		
		
		result.setAppointmentDate(joinDateAndTime(consultResponse.getAppointmentDate(),consultResponse.getAppointmentTime()));
		result.setReferringDoctor(professionalSpecialist);
		result.setDemographic(demographic);
		result.setId(consultResponse.getId());
		result.setLastFollowUp(consultResponse.getFollowUpDate());
		result.setProvider(provider);
		result.setReferralDate(consultResponse.getReferralDate());
		result.setResponseDate(consultResponse.getResponseDate());
		result.setStatus(consultResponse.getStatus());
		result.setUrgency(consultResponse.getUrgency());

		if(consultResponse.getSendTo() != null && !consultResponse.getSendTo().isEmpty() && !consultResponse.getSendTo().equals("-1")) {
			result.setTeamName(consultResponse.getSendTo());	
		}
		
		return result;
	}
	
	private Date joinDateAndTime(Date date, Date time) {
		
		if(date == null || time == null) {
			return null;
		}
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
	
		Calendar timeCal = Calendar.getInstance();
		timeCal.setTime(time);
		
		cal.set(Calendar.HOUR_OF_DAY, timeCal.get(Calendar.HOUR_OF_DAY));
		cal.set(Calendar.MINUTE, timeCal.get(Calendar.MINUTE));
		cal.set(Calendar.SECOND, timeCal.get(Calendar.SECOND));
		
		return cal.getTime();
	}
	
	private void checkPrivilege(LoggedInInfo loggedInInfo, String privilege) {
		if(!securityInfoManager.hasPrivilege(loggedInInfo, "_con", privilege, null)) {
			throw new RuntimeException("Access Denied");
		}
	}
	
	public List<ProfessionalSpecialist> findByService(LoggedInInfo loggedInInfo, String serviceName) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		List<ProfessionalSpecialist> results = professionalSpecialistDao.findByService(serviceName);
		
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.findByService", "serviceName"+serviceName);
		
		
		return results;
	}
	
	public List<ProfessionalSpecialist> findByServiceId(LoggedInInfo loggedInInfo, Integer serviceId) {
		checkPrivilege(loggedInInfo, SecurityInfoManager.READ);
		
		List<ProfessionalSpecialist> results = professionalSpecialistDao.findByServiceId(serviceId);
		
		LogAction.addLogSynchronous(loggedInInfo,"ConsultationManager.findByServiceId", "serviceId"+serviceId);
		
		
		return results;
	}
	
	public void archiveConsultationRequest(Integer requestId) {
		ConsultationRequest c =  consultationRequestDao.find(requestId);
		if(c != null) {
			List<ConsultationRequestExt> exts = consultationRequestExtDao.getConsultationRequestExts(requestId);
			
			ConsultationRequestArchive a = new ConsultationRequestArchive();
			a.setAllergies(c.getAllergies());
			a.setAppointmentDate(c.getAppointmentDate());
			a.setAppointmentInstructions(c.getAppointmentInstructions());
			a.setAppointmentTime(c.getAppointmentTime());
			a.setClinicalInfo(c.getClinicalInfo());
			a.setConcurrentProblems(c.getConcurrentProblems());
			a.setCurrentMeds(c.getCurrentMeds());
			a.setDemographicId(c.getDemographicId());
			a.setFdid(c.getFdid());
			a.setFollowUpDate(c.getFollowUpDate());
			a.setLastUpdateDate(c.getLastUpdateDate());
			a.setLetterheadAddress(c.getLetterheadAddress());
			a.setLetterheadFax(c.getLetterheadFax());
			a.setLetterheadName(c.getLetterheadName());
			a.setLetterheadPhone(c.getLetterheadPhone());
			a.setLookupListItem(c.getLookupListItem());
			a.setPatientWillBook(c.isPatientWillBook());
		//	a.setProfessionalSpecialist(c.getProfessionalSpecialist());
			a.setProviderNo(c.getProviderNo());
			a.setReasonForReferral(c.getReasonForReferral());
			a.setReferralDate(c.getReferralDate());
			a.setRequestId(requestId);
			a.setSendTo(c.getSendTo());
			a.setServiceId(c.getServiceId());
			a.setSignatureImg(c.getSignatureImg());
			a.setSiteName(c.getSiteName());
			a.setSource(c.getSource());
			a.setStatus(c.getStatus());
			a.setStatusText(c.getStatusText());
			a.setUrgency(c.getUrgency());
			
			
			consultationRequestArchiveDao.persist(a);
			
			if(c.getProfessionalSpecialist() != null) {
				ProfessionalSpecialist professionalSpecialist=professionalSpecialistDao.find(c.getProfessionalSpecialist().getId());
	            if( professionalSpecialist != null ) {
	                 a.setProfessionalSpecialist(professionalSpecialist);
	                 consultationRequestArchiveDao.merge(a);
	            }
			}
			
			
			//List<ConsultationRequestExtArchive> aExts = new ArrayList<ConsultationRequestExtArchive>();
			for(ConsultationRequestExt e:exts) {
				ConsultationRequestExtArchive aext = new ConsultationRequestExtArchive();
				aext.setDateCreated(e.getDateCreated());
				aext.setKey(e.getKey());
				aext.setOriginalId(e.getId());
				aext.setRequestId(requestId);
				aext.setValue(e.getValue());
				aext.setConsultationRequestArchiveId(a.getId());
				//aExts.add(aext);
				
				consultationRequestExtArchiveDao.persist(aext);
			}
		}
	}

	/**
	 * Saves or updates consultation request extras depending on if the key already exists in the table
	 * @param requestId The id of the consultation request the extras are linked to
	 * @param extras A list of extras to save or update
	 */
	public void saveOrUpdateExts(int requestId, List<ConsultationRequestExt> extras) {
		List<ConsultationRequestExt> existingExtras = consultationRequestExtDao.getConsultationRequestExts(requestId);
		Map<String, ConsultationRequestExt> extraMap = getExtsAsMap(existingExtras);
		List<AbstractModel<?>> newExtras = new ArrayList<>();
		
		for (ConsultationRequestExt extra : extras) {
			extra.setRequestId(requestId);
			
			// If the map contains the key then the extra already exists and will be updated, else saves a new one
			if (extraMap.containsKey(extra.getKey())) {
				ConsultationRequestExt savedExtra = extraMap.get(extra.getKey());
				
				extra.setId(savedExtra.getId());
				extra.setDateCreated(savedExtra.getDateCreated());
				
				// If the value isn't the same, update it
				if (!savedExtra.getValue().equals(extra.getValue())) {
					consultationRequestExtDao.merge(extra);
				}
			} else {
				extra.setDateCreated(new Date());
				newExtras.add(extra);
			}
		}

		// If there are new extras, batch persists them
		if (!newExtras.isEmpty()) {
			consultationRequestExtDao.batchPersist(newExtras);
		}
	}
	
	public Map<String, ConsultationRequestExt> getExtsAsMap(List<ConsultationRequestExt> extras) {
		Map<String, ConsultationRequestExt> extraMap = new HashMap<>();
		
		for (ConsultationRequestExt extra : extras) {
			extraMap.put(extra.getKey(), extra);
		}

		return extraMap;
	}

	public Map<String, String> getExtValuesAsMap(List<ConsultationRequestExt> extras) {
		Map<String, String> extraMap = new HashMap<>();

		for (ConsultationRequestExt extra : extras) {
			extraMap.put(extra.getKey(), extra.getValue());
		}

		return extraMap;
	}

	public Map<String, String> getArchivedExtValuesAsMap(List<ConsultationRequestExtArchive> extras) {
		Map<String, String> extraMap = new HashMap<>();

		for (ConsultationRequestExtArchive extra : extras) {
			extraMap.put(extra.getKey(), extra.getValue());
		}

		return extraMap;
	}
}

package org.oscarehr.prevention.reports;

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

import java.text.DateFormat;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.oscarehr.common.dao.BillingONCHeader1Dao;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.dao.forms.FormsDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Prevention;
import org.oscarehr.managers.DemographicManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.ws.rest.to.model.PreventionSearchConfigTo1;
import org.oscarehr.ws.rest.to.model.PreventionSearchTo1;

import oscar.oscarPrevention.PreventionData;
import oscar.oscarPrevention.reports.PreventionReportUtil;
import oscar.oscarPrevention.reports.ReportItem;
import oscar.util.UtilDateUtilities;

public class ReportBuilder {
	private static Logger logger = MiscUtils.getLogger();
	
	public static DemographicManager demographicManager =  SpringUtils.getBean(DemographicManager.class);
	OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
	BillingONCHeader1Dao billingONCHeader1Dao = SpringUtils.getBean(BillingONCHeader1Dao.class);
	

	public Report runReport(LoggedInInfo loggedInInfo,String providerNo, PreventionSearchTo1 preventionSearchTo1) {
		//Does it need anything else?
		//First get Denominator of patients that the report wants to look at.
		PreventionSearchTo1 searchConfig = preventionSearchTo1;
		List<Integer> demographicList = getDemographicDenominator( loggedInInfo,searchConfig, providerNo);
		
		logger.error("remove but "+demographicList.size());
	    
		Report report = new Report();
		List<ReportItem> items = new ArrayList<ReportItem>();
		//Circle through the denominator to see if they match the criteria
		for(Integer demographicNo:demographicList) {
			ReportItem item = processForNumerator(loggedInInfo, searchConfig, providerNo, demographicNo,report);
			
			populateDemographicInfo(loggedInInfo,item,searchConfig.getAgeAsOf());
			items.add(item);
		}
		
		Collections.sort(items);
		report.setItems(items);
		return report;
	}
	
	private void populateDemographicInfo(LoggedInInfo loggedInInfo,ReportItem item,Date asofDate ) {
		Demographic demographic = demographicManager.getDemographic(loggedInInfo, item.getDemographicNo());
		item.setDob(demographic.getBirthDay().getTime());
		item.setSex(demographic.getSex());
		item.setLastname(demographic.getLastName());
		item.setFirstname(demographic.getFirstName());
		item.setHin(demographic.getHin());
		item.setPhone(demographic.getPhone());
		item.setAddress(demographic.getAddress());
		item.setEmail(demographic.getEmail());
		item.setAge(demographic.getAgeAsOf(asofDate));
		item.setRosteringDoc(demographic.getProvider().getFormattedName());
		
		Appointment appt = appointmentDao.findNextAppointment(item.getDemographicNo());
		if(appt != null) {
			item.setNextAppt(appt.getAppointmentDate());
		}
			
		//Age? or calc it?
		
	}
	
	/*
	private ArrayList<Map<String,Object>> getPreventionData(LoggedInInfo loggedInInfo,PreventionSearchConfigTo1 preventionSearchConfig,Integer demographicNo ){
		ArrayList<Map<String,Object>>  prevs = PreventionData.getPreventionData(loggedInInfo, preventionSearchConfig.getName(),demographicNo);
        PreventionData.addRemotePreventions(loggedInInfo, prevs, demographicNo,preventionSearchConfig.getName(),null);
        return prevs;
	}
	*/
	private List<Prevention> getPreventionData(LoggedInInfo loggedInInfo,PreventionSearchConfigTo1 preventionSearchConfig,Integer demographicNo ){
		List<Prevention>  prevs = PreventionData.getPrevention(loggedInInfo, preventionSearchConfig.getName(),demographicNo);
        PreventionData.addRemotePreventions(loggedInInfo, prevs, demographicNo,preventionSearchConfig.getName(),null);
        return prevs;
	}
	/*
	private ArrayList<Map<String,Object>> removeFutureItems(ArrayList<Map<String,Object>> list,Date asOfDate){
	       ArrayList<Map<String,Object>> noFutureItems = new ArrayList<Map<String,Object>>();
	       DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
	       for (int i =0; i < list.size(); i ++){
	    	   Map<String,Object> h = list.get(i);
	            String prevDateStr = (String) h.get("prevention_date");
	            Date prevDate = null;
	            try{
	                prevDate = formatter.parse(prevDateStr);
	            }catch (Exception e){
	            	//empty
	            }

	            if (prevDate != null && prevDate.before(asOfDate)){
	               noFutureItems.add(h);
	            }
	       }
	       return noFutureItems;
	   }
	*/
	
	private List<Prevention> removeFutureItems(List<Prevention> list,Date asOfDate){
		List<Prevention> noFutureItems = new ArrayList<Prevention>();
	      DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
	      for(Prevention prevention:list) {
	    	  	if(prevention.getPreventionDate() != null && prevention.getPreventionDate().before(asOfDate)) {
	    	  		noFutureItems.add(prevention);
	    	  	}
	    	  		
	      }
	      return noFutureItems;
	}
	    
	/*
	boolean ineligible(Map<String,Object> h){
	       boolean ret =false;
	       if ( h.get("refused") != null && ((String) h.get("refused")).equals("2")){
	          ret = true;
	       }
	       return ret;
	   }
	
	boolean ineligible(ArrayList<Map<String,Object>> list){
	       for (int i =0; i < list.size(); i ++){
	    	   Map<String,Object> h = list.get(i);
	           if (ineligible(h)){
	               return true;
	           }
	       }
	       return false;
	   }
	
	boolean ineligible(List<ArrayList<Map<String,Object>>> prevs){
	       for (ArrayList<Map<String,Object>> prev: prevs){
	    	   	  if (ineligible(prev)){
	               return true;
	          }
	       }
	       return false;
	   }
	*/
	private void setNoInfo(ReportItem item) {
		item.setRank(1);
		item.setState("No Info");
		item.setColor("Magenta");
	}
	
	private void setUptoDate(ReportItem item) {
		item.setRank(4);
		item.setState("Up to date");
		item.setBonusStatus("Y");
		item.setColor("green");
	}
	
	private void setRefused(ReportItem item) {
		item.setRank(3);
		item.setState("Refused");
		item.setColor("orange");
	}
	
	private void setOverdue(ReportItem item) {
		item.setRank(2);
		item.setState("Overdue");
		item.setColor("red");
	}
	
	private void setIneligible(ReportItem item) {
		item.setRank(5);
		item.setState("Ineligible");
		item.setColor("blue");
	}
	
	
	
	
	
	private ReportItem processForNumerator(LoggedInInfo loggedInInfo,PreventionSearchTo1 searchConfig,String providerNo,Integer demographicNo,Report report){
		ReportItem item = new ReportItem();
		item.setDemographicNo(demographicNo);
		report.incrementTotalPatients();
		////////from PAP
		
		
		if(searchConfig.getExclusionCodes() != null && !searchConfig.getExclusionCodes().isEmpty()) {
			//Need to search billing for the exclusion Code
			//If found return as ineligible, if not continue on.
			Calendar startDate = null;  //???????
			Calendar endDate = null;
			boolean exclusionCodeFound = false;
			for(String serviceCode:searchConfig.getExclusionCodes()) {
				if(billingONCHeader1Dao.billedBetweenTheseDays(serviceCode,demographicNo, startDate,  endDate)) {
					exclusionCodeFound = true;
				}
			}
			if(exclusionCodeFound) { 
				report.incrementIneligiblePatients();
				setIneligible(item);
			}
		}
		
		if(searchConfig.getTrackingCodes() != null && !searchConfig.getTrackingCodes().isEmpty()) {
			//Need to search billing for the tracking Codes
			//If found return as up to date, if not continue on.
			
			Calendar startDate = null;  //???????
			Calendar endDate = null;
			boolean trackingCodeFound = false;
			for(String serviceCode:searchConfig.getTrackingCodes()) {
				if(billingONCHeader1Dao.billedBetweenTheseDays(serviceCode,demographicNo, startDate,  endDate)) {
					trackingCodeFound = true;
				}
			}
			if(trackingCodeFound) { 
				report.incrementUp2Date();
				setUptoDate(item);
			}
			
		}
		
		
		if(searchConfig.getPreventions() == null || searchConfig.getPreventions().isEmpty()) {
			//If the configuration does not have any prevention configuration, return no info. 
			//Most likely this has been run in error but catching this condition here.
			setNoInfo(item);
			logger.error("Preventions was empty returning no Info");
	    		return item;
		}

		
		boolean noPreventionsFound = true;
		boolean requirementsMet = true;
		boolean hasRefusedPrevention = false;
		
		Date lastPreventionDate = null;
		for(PreventionSearchConfigTo1 preventionSearchConfig : searchConfig.getPreventions()) {
			List<Prevention> prev = getPreventionData(loggedInInfo,preventionSearchConfig,demographicNo );

			List<Prevention> noFutureItem = removeFutureItems(prev, preventionSearchConfig.getAsOfDate());
			logger.info("number of items for patient "+demographicNo+" = "+noFutureItem.size()+"/"+prev.size());
			
			if(noFutureItem.size() > 0) {
				noPreventionsFound = false; 
				if(preventionSearchConfig.getDateCalcType() == PreventionSearchConfigTo1.ASOFDATE) {  //PAP MAM FOBT FLU etc style 
					//PAP prevention within 42 Months prior to March 31st 
					//name: PAP  asOfDate:Mar 31st cutoffTimefromAsOfDate: 42 
					int requirementMet = 0;
					Calendar cutOffTime = Calendar.getInstance();
			        cutOffTime.setTime(preventionSearchConfig.getAsOfDate());
			        cutOffTime.add(Calendar.MONTH,-preventionSearchConfig.getCutoffTimefromAsOfDate());
					
			        boolean first = true;
					for(Prevention lastPrevention : noFutureItem) {
						if(first && lastPrevention.isRefused()) {
							hasRefusedPrevention = true;
 						}
						first = false;
						
						if(lastPrevention.isComplete() && lastPrevention.getPreventionDate().after(cutOffTime.getTime())) {
							requirementMet++;
						}
						if(lastPrevention.isComplete()) {
							if(lastPreventionDate == null || lastPreventionDate.before(lastPrevention.getPreventionDate())) {
								lastPreventionDate = lastPrevention.getPreventionDate();
							}
						}
						
					}
					
					if(requirementMet < preventionSearchConfig.getHowManyPreventions()) {
						requirementsMet = false;
					}
				}else if (preventionSearchConfig.getDateCalcType() == PreventionSearchConfigTo1.BYAGE) {
					
				}
			}
		}
		
		if(lastPreventionDate != null) {
			item.setLastDate(lastPreventionDate);
			item.setNumMonths(UtilDateUtilities.getNumMonths(lastPreventionDate,searchConfig.getRosterAsOf())+" months");
			
		}
		
		if(noPreventionsFound) {
			//If not preventions were found return No Info
			setNoInfo(item);
			logger.error("No preventions found for this patient returning no Info");
			return item;
		}
		
		if(requirementsMet) {
			setUptoDate(item);
			report.incrementUp2Date();
			return item;
		}
		
		if(hasRefusedPrevention) {
			setRefused(item);
			return item;
		}
		
		setOverdue(item);
		return item;
		
    
        /*
         * 5 States:
         *   1. No Info 
         *   2. Overdue
         *   3. Refused
         *   4. Up to date
         *   5. Ineligible -exclusion codes
         */
        
       /*
        if(ineligible(prevs)){
        		item.setRank(5);
        		item.setLastDate("------");
        		item.setState("Ineligible");
        		item.setNumMonths("------");
        		item.setColor("grey");
          // inList++;  // Jan 2 2019 commented this out for now, will probably have to incorporate it into the report object
        }else if (noFutureItems.size() == 0){// no info
	        	
	        	item.setRank(1);
	    		item.setLastDate("------");
	    		item.setState("No Info");
	    		item.setNumMonths("------");
	    		item.setColor("Magenta");
        	
        }else{
           DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
           Map<String,Object> h = noFutureItems.get(noFutureItems.size()-1);
        
           boolean refused = false;
           boolean dateIsRefused = false;
           if ( h.get("refused") != null && ((String) h.get("refused")).equals("1")){
              refused = true;
              dateIsRefused = true;
           }

           String prevDateStr = (String) h.get("prevention_date");


           if (refused && noFutureItems.size() > 1){
               log.debug("REFUSED AND PREV IS greater than one for demo "+demo);
               for (int pr = (noFutureItems.size() -2) ; pr > -1; pr--){
                   log.debug("pr #"+pr);
                   Map<String,Object> h2 = noFutureItems.get(pr);
                   log.debug("pr #"+pr+ "  "+((String) h2.get("refused")));
                   if ( h2.get("refused") != null && ((String) h2.get("refused")).equals("0")){
                       prevDateStr = (String) h2.get("prevention_date");
                       dateIsRefused = false;
                       log.debug("REFUSED prevDateStr "+prevDateStr);
                       pr = 0;
                   }
               }
           }
           Date prevDate = null;
           try{
              prevDate = formatter.parse(prevDateStr);
           }catch (Exception e){
           	//extra
           }



           Calendar cal = Calendar.getInstance();
           cal.add(Calendar.YEAR, -3);
           Date dueDate = cal.getTime();
           cal.add(Calendar.MONTH,-6);
           Date cutoffDate = cal.getTime();

           Calendar cal2 = GregorianCalendar.getInstance();
           cal2.add(Calendar.YEAR, -3);

           //cal2.roll(Calendar.YEAR, -1);
           cal2.add(Calendar.MONTH,-6);
           Date cutoffDate2 = cal2.getTime();

           log.debug("cut 1 "+cutoffDate.toString()+ " cut 2 "+cutoffDate2.toString());


           String numMonths = "------";
           if ( prevDate != null){
              int num = UtilDateUtilities.getNumMonths(prevDate,asofDate);
              numMonths = ""+num+" months";
           }

           // if prevDate is less than as of date and greater than 2 years prior
           Calendar bonusEl = Calendar.getInstance();
           bonusEl.setTime(asofDate);
           bonusEl.add(Calendar.MONTH,-42);
           //bonusEl.add(Calendar.YEAR,-2);
           Date bonusStartDate = bonusEl.getTime();

           log.debug("\n\n\n prevDate "+prevDate);
           log.debug("bonusEl date "+bonusStartDate+ " "+bonusEl.after(prevDate));
           log.debug("asofDate date"+asofDate+" "+asofDate.after(prevDate));

           //IF REFUSED SHOULD CHECK TO SEE IF


           if (!dateIsRefused && bonusStartDate.before(prevDate) && asofDate.after(prevDate)){
              prd.bonusStatus = "Y";
              prd.billStatus = "Y";
              done++;
           }
           //outcomes
           log.debug("due Date "+dueDate.toString()+" cutoffDate "+cutoffDate.toString()+" prevDate "+prevDate.toString());
           log.debug("due Date  ("+dueDate.toString()+" ) After Prev ("+prevDate.toString() +" ) "+dueDate.after(prevDate));
           log.debug("cutoff Date  ("+cutoffDate.toString()+" ) before Prev ("+prevDate.toString() +" ) "+cutoffDate.before(prevDate));
           if (!refused && dueDate.after(prevDate) && cutoffDate.before(prevDate)){ // overdue
              prd.rank = 2;
              prd.lastDate = prevDateStr;
              prd.state = "due";
              prd.numMonths = numMonths;
              prd.color = "yellow"; //FF00FF
              if (!prd.bonusStatus.equals("Y")){
                 prd.bonusStatus = "Y";
                 doneWithGrace++;
              }

           } else if (!refused && cutoffDate.after(prevDate)){ // overdue
              prd.rank = 2;
              prd.lastDate = prevDateStr;
              prd.state = "Overdue";
              prd.numMonths = numMonths;
              prd.color = "red"; //FF00FF

           } else if (refused){  // recorded and refused
              prd.rank = 3;
              prd.lastDate = prevDateStr;
              prd.state = "Refused";
              prd.numMonths = numMonths;
              prd.color = "orange"; //FF9933
           } else if (dueDate.before(prevDate)  ){  // recorded done
              prd.rank = 4;
              prd.lastDate = prevDateStr;
              prd.state = "Up to date";
              prd.numMonths = numMonths;
              prd.color = "green";
              //done++;
           }
        }
        letterProcessing( prd,"PAPF",asofDate);
        //returnReport.add(prd);  // 2019 We just return the item now 
		
		
		/////End pap
		
		
		return item;
		*/
	}
	
	private List<Integer> getDemographicDenominator(LoggedInInfo loggedInInfo,PreventionSearchTo1 frm,String provider){
		List<Integer> list = new ArrayList<Integer>();
		
		logger.debug("in buildQuery "+frm);

		
		StringBuilder stringBuffer = new StringBuilder("select demographic_no from demographic d "); // had , provider p / but i don't think i meed that

		Integer ageStyle = frm.getAgeStyle();
		Integer yearStyle = frm.getAgeCalc();
		String startYear = frm.getAge1();
		String endYear = frm.getAge2();
		String rosterStatus = frm.getRosterStat();
		
		// Should this be passed in, or put in the  String provider = frm.getProviderNo();

		
		Integer sex = frm.getSex();

		String asofDate = "CURRENT_DATE";
		logger.error("what is date "+frm.getAgeAsOf());
		if(yearStyle == 1) {
			Format formatter = new SimpleDateFormat("yyyy-MM-dd");     
			asofDate = "'" + formatter.format(frm.getAgeAsOf()) + "'";
		}

		// is this needed ??? oscar.oscarMessenger.util.MsgStringQuote s = new oscar.oscarMessenger.util.MsgStringQuote();
		
		boolean theWhereFlag = true;
		boolean theFirstFlag = true;

		boolean getprovider = false;
/*
		int yStyle = 0;
		if(yearStyle != null && yearStyle == 1) {
			yStyle = 1;
		}
*/		
		MiscUtils.getLogger().debug("date style" + ageStyle);
		logger.info("where before age " +theWhereFlag);
		switch (ageStyle) {
			case 1:
				theWhereFlag = whereClause(stringBuffer, theWhereFlag);
				logger.info("where 1? " +theWhereFlag);
				if (yearStyle.equals("1")) {
					stringBuffer.append(" ( ( YEAR(" + asofDate + ") -YEAR (DATE_FORMAT(CONCAT((d.year_of_birth), '-', (d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'))) - (RIGHT(" + asofDate + ",5)<RIGHT(DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'),5)) <  " + startYear + " ) ");
				} else {
					stringBuffer.append(" ( YEAR(" + asofDate + ") - d.year_of_birth < " + startYear + "  ) ");
				}
				theFirstFlag = false;
				break;
			case 2:
				theWhereFlag = whereClause(stringBuffer, theWhereFlag);
				//if (ageStyle.equals("1")){
				stringBuffer.append(" ( ( YEAR(" + asofDate + ") -YEAR (DATE_FORMAT(CONCAT((d.year_of_birth), '-', (d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'))) - (RIGHT(" + asofDate + ",5)<RIGHT(DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'),5)) >  " + startYear + " ) ");
				//}else{
				//   stringBuffer.append(" ( YEAR("+asofDate+") - year_of_birth > "+startYear+"  ) ");
				//}
				theFirstFlag = false;
				break;
			case 3:
				theWhereFlag = whereClause(stringBuffer, theWhereFlag);
				if (yearStyle.equals("1")) {
					stringBuffer.append(" ( ( YEAR(" + asofDate + ") -YEAR (DATE_FORMAT(CONCAT((d.year_of_birth), '-', (d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'))) - (RIGHT(" + asofDate + ",5)<RIGHT(DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'),5)) =  " + startYear + " ) ");
				} else {
					stringBuffer.append(" ( YEAR(" + asofDate + ") - d.year_of_birth = " + startYear + "  ) ");
				}
				theFirstFlag = false;
				break;
			case 4:
				theWhereFlag = whereClause(stringBuffer, theWhereFlag);
				MiscUtils.getLogger().debug("age style " + ageStyle);
				if (!yearStyle.equals("2")) {
					// stringBuffer.append(" ( ( YEAR("+asofDate+") -YEAR (DATE_FORMAT(CONCAT((year_of_birth), '-', (month_of_birth),'-',(date_of_birth)),'%Y-%m-%d'))) - (RIGHT("+asofDate+",5)<RIGHT(DATE_FORMAT(CONCAT((year_of_birth),'-',(month_of_birth),'-',(date_of_birth)),'%Y-%m-%d'),5)) >  "+startYear+" and ( YEAR("+asofDate+") -YEAR (DATE_FORMAT(CONCAT((year_of_birth), '-', (month_of_birth),'-',(date_of_birth)),'%Y-%m-%d'))) - (RIGHT("+asofDate+",5)<RIGHT(DATE_FORMAT(CONCAT((year_of_birth),'-',(month_of_birth),'-',(date_of_birth)),'%Y-%m-%d'),5)) <  "+endYear+"  ) ");
					MiscUtils.getLogger().debug("VERIFYING INT" + startYear);
					//check to see if its a number
					if (verifyInt(startYear)) {
						stringBuffer.append(" ( ( YEAR(" + asofDate + ") -YEAR (DATE_FORMAT(CONCAT((d.year_of_birth), '-', (d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'))) - (RIGHT(" + asofDate + ",5)<RIGHT(DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'),5)) >  " + startYear + " ) ");
					} else {
						String interval = getInterval(startYear);
						stringBuffer.append(" ( date_sub(" + asofDate + ",interval " + interval + ") >= DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d')   ) ");
					}
					stringBuffer.append(" and ");
					if (verifyInt(endYear)) {
						stringBuffer.append(" ( ( YEAR(" + asofDate + ") -YEAR (DATE_FORMAT(CONCAT((d.year_of_birth), '-', (d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'))) - (RIGHT(" + asofDate + ",5)<RIGHT(DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d'),5)) <  " + endYear + "  ) ");
					} else {
						///
						String interval = getInterval(endYear);
						stringBuffer.append(" ( date_sub(" + asofDate + ",interval " + interval + ") < DATE_FORMAT(CONCAT((d.year_of_birth),'-',(d.month_of_birth),'-',(d.date_of_birth)),'%Y-%m-%d')   ) ");
					}
				} else {
					stringBuffer.append(" ( YEAR(" + asofDate + ") - d.year_of_birth > " + startYear + "  and YEAR(" + asofDate + ") - d.year_of_birth < " + endYear + "  ) ");
				}
				theFirstFlag = false;
				break;
		}
		logger.info("where after age " +theWhereFlag);
		/*  This is done after
		  if (rosterStatus != null) {
			whereClause();
			firstClause();
			stringBuffer.append(" ( ");
			for (int i = 0; i < rosterStatus.length; i++) {
				theFirstFlag = 1;
				if (i == (rosterStatus.length - 1)) {
					stringBuffer.append(" d.roster_status = '" + rosterStatus[i] + "' )");
				} else {
					stringBuffer.append(" d.roster_status = '" + rosterStatus[i] + "' or  ");
				}
			}
		}*/

		
/* This is done after now i thikn
		if (providers != null) {
			whereClause();
			firstClause();
			stringBuffer.append(" ( ");
			for (int i = 0; i < providers.length; i++) {
				theFirstFlag = 1;
				if (i == (providers.length - 1)) {
					stringBuffer.append(" d.provider_no = '" + providers[i] + "' )");
				} else {
					stringBuffer.append(" d.provider_no = '" + providers[i] + "' or  ");
				}
			}
		}
*/
		logger.info("where" +theWhereFlag);
		if(sex != null) {
			switch (sex) {
				case 1:
					theWhereFlag = whereClause(stringBuffer, theWhereFlag);
					theFirstFlag = firstClause(stringBuffer, theFirstFlag);
					stringBuffer.append(" ( d.sex =  'F' )");
					theFirstFlag = false;
					break;
				case 2:
					theWhereFlag = whereClause(stringBuffer, theWhereFlag);
					theFirstFlag = firstClause(stringBuffer, theFirstFlag);
					stringBuffer.append(" ( d.sex = 'M' )");
					theFirstFlag = false;
					break;
			}
		}

		//removed roster_status condition in place more complex check below
/* only check if rostered
		if (getprovider) {
			whereClause(stringBuffer, theWhereFlag);
			firstClause();
			stringBuffer.append(" ( d.provider_no = p.provider_no )");
		}
*/		
		
		

		logger.debug("SEARCH SQL STATEMENT \n" + stringBuffer.toString());
		java.util.ArrayList<ArrayList<String>> searchedArray = new java.util.ArrayList<ArrayList<String>>();
		try {
			MiscUtils.getLogger().info(stringBuffer.toString());

			FormsDao dao = SpringUtils.getBean(FormsDao.class);
			List<Object[]> demographicList = dao.runNativeQuery(stringBuffer.toString()); 
			logger.debug(" number of results from query "+demographicList.size());
			for (Object[] o : demographicList) {
				if (o == null) {
					continue;
				}
				
				//String demoNo = null;
				Integer demographic = (Integer) o[0];
				Date rosteredDate = frm.getAgeAsOf();
				if(rosteredDate == null) {
					rosteredDate = new Date();
				}
				// need to check if they were rostered at this point to this provider  (asofRosterDate is only set if this is being called from prevention reports)
				if (demographic != null && frm.getRosterAsOf() != null && provider != null ) {
					//Only checking the first doc.  Only one should be included for finding the cumulative bonus
					try {
						if (!PreventionReportUtil.wasRosteredToThisProvider(loggedInInfo, demographic, frm.getRosterAsOf(), provider)) {
							logger.info("Demographic :" + demographic + " was not included in returned array because they were not rostered to " + provider + " on " + frm.getRosterAsOf());
							continue;             //change this back to info
						} else {
							logger.error("Demographic :" + demographic + " was included in returned array because they were not rostered to " + provider + " on " + frm.getRosterAsOf());
							list.add(demographic);              //change this back to info
						}
					} catch (NumberFormatException e) {
						logger.error("Error", e);
					} catch (Exception e) {
						logger.error("Error", e);
					}
				}

				

			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("Error", e);
		}

		

		
		return list;
	}
	
	private boolean whereClause(StringBuilder stringBuffer, boolean theWhereFlag) {
		if (stringBuffer != null) {
			logger.info("where " +stringBuffer.toString());
			if (theWhereFlag) {
				stringBuffer.append(" where ");
				theWhereFlag = false;
			}
		}
		return theWhereFlag;
	}

	private boolean firstClause(StringBuilder stringBuffer, boolean theFirstFlag) {
		if (!theFirstFlag) {
			stringBuffer.append(" and ");
			theFirstFlag = false;
		}
		return theFirstFlag;
	}
	
	boolean verifyInt(String str) {
		boolean verify = true;
		try {
			Integer.parseInt(str);
		} catch (Exception e) {
			verify = false;
		}
		return verify;
	}

	String getInterval(String startYear) {
		MiscUtils.getLogger().debug("in getInterval startYear " + startYear);
		String str = "";
		if (startYear.charAt(startYear.length() - 1) == 'm') {
			str = startYear.substring(0, (startYear.length() - 1)) + " month";
		}
		MiscUtils.getLogger().debug(str);
		return str;
	}

}
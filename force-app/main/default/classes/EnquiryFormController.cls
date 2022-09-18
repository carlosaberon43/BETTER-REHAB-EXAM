/**
 * @description       : 
 * @author            : CarloSaberon
 * @group             : 
 * @last modified on  : 09-18-2022
 * @last modified by  : CarloSaberon
**/

public without sharing class EnquiryFormController {

    public static String subjectTemplate = '{0} - Clinician: {1} Contact: {2} Service: {3}';
    public static Enquiry__c enquiryDetails; 
    /**
    * @description Return List of Clinician based on relevance
    * @author CarloSaberon | 09-18-2022 
    * @param enquiryId 
    * @return List<ClinicianWrapper> 
    **/
    public static List<ClinicianEnquiryWrapper> availableClinicians(Id enquiryId){
        
        enquiryDetails = DMLExtensions.getEnquiryDetails(enquiryId); // Queries enquiry and related contacted details

        if(enquiryDetails == null) { // No contact Related to Enquiry error thrown
            throw new EnquiryFormControllerException(Constants.NO_CONTACT_ENQURY); 
        }

        List<Clinician__c> availableClinicians =  DMLExtensions.getCliniciansByService(enquiryDetails);  // Queries clinicians and events based on appointment date on enquiry and service requested

        if(availableClinicians.isEmpty()) { // If no clinicians suitable for the service requested error thrown no available clinicians
            throw new EnquiryFormControllerException(Constants.NO_CLINICIANS_ON_DISCIPLINE_REQUESTED); 
        }

        List<ClinicianEnquiryWrapper> clinicianList = new List<ClinicianEnquiryWrapper>(); // Wrapper class that sorts and holds the available clinicians based on parameters and availability

        for(Clinician__c cc : availableClinicians){

            Integer parametersCounter = matchEnquirytoClinician(cc, enquiryDetails);

            ClinicianEnquiryWrapper cw = new ClinicianEnquiryWrapper(cc, enquiryDetails.Appointment_Date__c);
            cw.checkAvailableSchedules(); // List all available schedule and time for the appointment date requested
            cw.sortRelevance(parametersCounter); // Sort them by relevance = total availability and matching parameters
            
            clinicianList.add(cw);
        }
        return clinicianList;
    }

    /**
    * @description Match Enquiry and Clinician Based on Parameters
    * @author CarloSaberon | 09-18-2022 
    * @param clinician 
    * @param enquiry 
    * @return Integer 
    **/
    public static Integer matchEnquirytoClinician(Clinician__c clinician, Enquiry__c enquiry){
        Integer parameterCounter = 0;
        
        if(clinician.Gender__c == enquiry.Gender_Preference__c){
            parameterCounter += 1;
        }

        if((enquiry.Medium__c == Constants.HOME_BASED || enquiry.Medium__c == Constants.IN_CLINIC) && clinician.Office__c == enquiry.Contact__r.MailingState){
            parameterCounter += 1;
        }

        if(clinician.Languages__c == enquiry.Contact__r.Languages__c){
            parameterCounter += 1;
        }
        parameterCounter = checkAgePreferanceClinician(parameterCounter, clinician.Age_Load_Preference__c, (Integer)enquiry.Contact__r.Age__c);
        parameterCounter = checkLanguageSpoken(parameterCounter, clinician.Languages__c, enquiry.Contact__r.Languages__c);

        return parameterCounter;
        
    }

    private static Integer checkAgePreferanceClinician(Integer parameterCounter, String ageLoad, Integer contactAge){
        for(String preferredAge : ageLoad.split(';')){
            if(preferredAge.contains('-')){
               List<String> ageBracket = preferredAge.split('-');
               if(contactAge >= Integer.valueOf(ageBracket[0]) && contactAge <= Integer.valueOf(ageBracket[1])){
                   parameterCounter += 1;
               } 
            }else if(contactAge >= Integer.valueOf(preferredAge)){
                parameterCounter += 1;
                
            }
        }
        return parameterCounter;
    }

    private static Integer checkLanguageSpoken(Integer parameterCounter, String clinicianLanguage, String contactLanguages){
        List<String> conLanguages = contactLanguages.split(';');
        return conLanguages.contains(clinicianLanguage) ? parameterCounter += 1 : parameterCounter;
    }


    public static void scheduleEnquiry(String timeSelected, Id clinicianId, String clinicianName){
        String contactName = enquiryDetails.Contact__r.FirstName+' '+enquiryDetails.Contact__r.LastName;

        List<String> timeStartEnd = timeSelected.split('-');
        // Datetime newInstance(Integer year, Integer month, Integer day, Integer hour, Integer minute, Integer second)
        DateTime startTime = Datetime.newInstance(enquiryDetails.Appointment_Date__c.year(), enquiryDetails.Appointment_Date__c.month(), enquiryDetails.Appointment_Date__c.day(), Integer.valueOf(timeStartEnd[0]),0,0);
        DateTime endTime = Datetime.newInstance(enquiryDetails.Appointment_Date__c.year(), enquiryDetails.Appointment_Date__c.month(), enquiryDetails.Appointment_Date__c.day(), Integer.valueOf(timeStartEnd[1]),0,0);


        String fromToEnd = startTime.format('MM-dd-yyyy h:mm a') +' to '+endTime.format('h:mm a');
        List<Object> parameters = new List<Object> {fromToEnd, clinicianName, contactName,  enquiryDetails.Service_Requested__c};
        String subjectFormatted = String.format(subjectTemplate, parameters);


        Event ev = new Event();
        ev.Subject = subjectFormatted;
        ev.StartDateTime = startTime;
        ev.EndDateTime = endTime;
        ev.WhoId = enquiryDetails.Contact__c;
        ev.WhatId = clinicianId;

        insert ev;
    }


    public class EnquiryFormControllerException extends Exception{}
}

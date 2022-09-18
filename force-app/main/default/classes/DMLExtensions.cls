/**
 * @description       : 
 * @author            : CarloSaberon
 * @group             : 
 * @last modified on  : 09-18-2022
 * @last modified by  : CarloSaberon
**/
public inherited sharing class DMLExtensions{

    /**
    * @description this will return the enquiry details and contact related to it
    * @author CarloSaberon | 09-18-2022 
    * @param recordId = Enquiry Record Id
    * @return Enquiry__c 
    **/
    public static Enquiry__c getEnquiryDetails(Id recordId){
        
        Enquiry__c enquiry =  [SELECT Id,
                               Contact__r.FirstName,
                               Contact__r.LastName,
                               Contact__r.Age__c,
                               Contact__r.MailingState,
                               Contact__r.Languages__c,
                               Appointment_Date__c,
                               Gender_Preference__c,
                               Medium__c,
                               Service_Requested__c,
                               Status__c
                               FROM Enquiry__c 
                               WHERE Id = :recordId AND Contact__c != null];
        return enquiry;
    }

    public static List<Clinician__c> getCliniciansByService(Enquiry__c enquiryDetails){
        return new List<Clinician__c>([SELECT Id,
                                       First_Name__c,
                                       Last_Name__c,
                                       Discipline__c,
                                       Age_Load_Preference__c,
                                       Office__c,
                                       Gender__c,
                                       Languages__c,
                                       (SELECT Id, StartDateTime, EndDateTime 
                                       FROM Events 
                                       WHERE ActivityDate = :enquiryDetails.Appointment_Date__c AND EndDate = :enquiryDetails.Appointment_Date__c
                                       ORDER BY StartDateTime)
                                       FROM Clinician__c 
                                       WHERE Discipline__c = :enquiryDetails.Service_Requested__c]);
    }
    
 }
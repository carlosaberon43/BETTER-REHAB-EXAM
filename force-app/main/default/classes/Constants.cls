/**
 * @description       : 
 * @author            : CarloSaberon
 * @group             : 
 * @last modified on  : 09-18-2022
 * @last modified by  : CarloSaberon
**/
public without sharing class Constants {
    
    /* Constants Variable to match certain criterias/parameters on enquiries/clinician/time available*/
    public static final String HOME_BASED = 'Home based',  IN_CLINIC = 'In-Clinic', TELEHEALTH = 'Telehealth';
    public static final Set<String> availableSchedules = new Set<String>{'08-09', // 8AM-9AM
                                                                         '09-10', // 9AM-10AM
                                                                         '10-11', // 10AM-11AM
                                                                         '11-12', // 11AM-12PM
                                                                         '12-13', // 12PM-1PM
                                                                         '13-14', // 1PM-2PM
                                                                         '14-15', // 2PM-3PM
                                                                         '15-16', // 3PM-4PM
                                                                         '16-17'};// 4PM-5PM

    /* Exceptions Message when Enquiry has no related records */
    public static final String NO_CLINICIANS_ON_DISCIPLINE_REQUESTED = 'No clinicians found based on service requested.';
    public static final String NO_CONTACT_ENQURY = 'No related contact on the enquiry';

}

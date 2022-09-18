/**
 * @description       : 
 * @author            : CarloSaberon
 * @group             : 
 * @last modified on  : 09-18-2022
 * @last modified by  : CarloSaberon
**/
public inherited sharing class ClinicianEnquiryWrapper implements Comparable{
    public Integer totalRelevance = 0;
    public Integer totalnAvailableTime= 0;
    public Boolean isFullyBooked = false;
    public Map<Date, Set<String>> availableTime = new Map<Date, Set<String>>();
    public Clinician__c clinicianName;
    public Date enquiryDate;

    public ClinicianEnquiryWrapper(Clinician__c clinicianName, Date enquiryDate){
        this.clinicianName = clinicianName;
        this.enquiryDate = enquiryDate;
        this.availableTime = new Map<Date, Set<String>>{enquiryDate => new Set<String>()};
    }

    public void checkAvailableSchedules(){

        Set<String> availableSchedules = new Set<String>(Constants.availableSchedules);
            
        Set<String> currentScheds = new Set<String>();

        for(Event ev : this.clinicianName.Events){
            String timePlotted = ev.StartDateTime.format('HH') +'-'+ev.EndDateTime.format('HH');
            availableSchedules.remove(timePlotted);
        }

        this.availableTime.get(enquiryDate).addAll(availableSchedules);
        this.totalnAvailableTime = this.availableTime.get(this.enquiryDate).size();
        this.isFullyBooked = totalnAvailableTime == 0 ? true : false;
    }

    public void sortRelevance(Integer parametersCounter){
        this.totalRelevance = parameterscounter + this.totalnAvailableTime;
    }


    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        ClinicianEnquiryWrapper compareToClinician = (ClinicianEnquiryWrapper)compareTo;
        if (totalRelevance > compareToClinician.totalRelevance){
            return 1;
        }else if (totalRelevance < compareToClinician.totalRelevance){
            return -1;
        }
        return 0;        
    }
}

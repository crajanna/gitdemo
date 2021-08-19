public without sharing  class EpHelper {

    public static Integer getContractYear(){
        Date currentDate = System.today(); //current date
            Integer currentYear = currentDate.Year(); //get year

            Date dtStart = Date.newInstance(currentYear,02,01); 
            Date dtEnd = Date.newInstance(currentYear,4,30); 

            if(!(currentDate > dtStart && currentDate  < dtEnd ))
            {
                currentYear = 2021;
            
            }
            return currentYear;
    }

}
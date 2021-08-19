trigger SetInitialLastName on Lead (before insert) {
    if(trigger.IsBefore && trigger.IsInsert){} 
   for(Lead l: Trigger.new){
            
       l.LastName = 'Customer';
      }
}
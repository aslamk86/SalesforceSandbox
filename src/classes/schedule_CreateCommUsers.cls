global class schedule_CreateCommUsers implements Schedulable {
   global void execute(SchedulableContext SC) {
      createCommunityUsers ccu = new createCommunityUsers(); 
      ccu.createCommUser();
   }
}
trigger EventConfirmationEmailTrigger on Event_Confirmation__c (before insert, after insert) {
    Event_Confirmation__c eventNew = trigger.new[0];

    if(trigger.isBefore && trigger.isInsert){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String confirmationCode = '';
        while (confirmationCode.length() < 6) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        confirmationCode += chars.substring(idx, idx+1);
        }
        eventNew.Confirmation_Code__c = confirmationCode;
    }
    if(trigger.isAfter && trigger.isInsert){

        EventConfirmationEmailHandler handler = new EventConfirmationEmailHandler();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage mailRegistrant = handler.registrationEmail(eventNew);

        emailList.add(mailRegistrant);

        Messaging.sendEmail(emailList);

    }
}
declare module "@salesforce/apex/EventConfirmationController.getCustomEvent" {
  export default function getCustomEvent(param: {id: any}): Promise<any>;
}
declare module "@salesforce/apex/EventConfirmationController.createEventConfirmation" {
  export default function createEventConfirmation(param: {eventId: any, firstName: any, lastName: any, email: any}): Promise<any>;
}
declare module "@salesforce/apex/EventConfirmationController.answersList" {
  export default function answersList(param: {object2: any, eventConfirmationId: any}): Promise<any>;
}
declare module "@salesforce/apex/EventConfirmationController.generateICS" {
  export default function generateICS(param: {recordId: any}): Promise<any>;
}

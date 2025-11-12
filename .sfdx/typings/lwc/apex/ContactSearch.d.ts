declare module "@salesforce/apex/ContactSearch.getContacts" {
  export default function getContacts(param: {textSearch: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactSearch.getAllReadyInvitedContacts" {
  export default function getAllReadyInvitedContacts(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactSearch.createInvitation" {
  export default function createInvitation(param: {ids: any, eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactSearch.sendEmails" {
  export default function sendEmails(param: {eventId: any}): Promise<any>;
}

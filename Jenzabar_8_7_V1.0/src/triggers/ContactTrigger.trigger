trigger ContactTrigger on Contact (after Update) {
    TriggerFactoryNew.CreateHandler('Contact');
}
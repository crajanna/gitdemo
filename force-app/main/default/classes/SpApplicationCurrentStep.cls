public with sharing class SpApplicationCurrentStep {
    public SpApplicationCurrentStep() {

    }

    @InvocableMethod
    public static List<Integer> getCurrentStep(List<String>  wrapperJson){
        system.debug('wrapperJson::: ' + wrapperJson);
        SpApplication myApp = (SpApplication)JSON.deserialize(wrapperJson[0], SpApplication.class);
        system.debug('wrapperJson::: ' + wrapperJson);
        system.debug('myApp.currentStep::: ' + myApp.currentStep);

        return new List<Integer>{myApp.currentStep};
    }
}
(function() {
    window.addEventListener("message", function(event) {
        if (event.origin !== "https://api.paymentwall.com") {
            return;
        }
        var eventData = JSON.parse(event.data);
        switch (eventData.event) {
            case 'widgetLoaded':
                window.JSInterface.widgetLoaded();
                break;
            case 'paymentProcessingStart':
                window.JSInterface.paymentProcessingStart();
                break;
            case 'paymentProcessingEnd':
                window.JSInterface.paymentProcessingEnd();
                break;
            case 'paymentSuccess':
                window.JSInterface.onSuccess();
                break;
        }
    }, false);
})()

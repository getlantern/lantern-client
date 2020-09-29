(function() {
    var launchIframeApproach = function(alt) {
        var iframe = document.createElement("iframe");
        iframe.style.border = "none";
        iframe.style.width = "1px";
        iframe.style.height = "1px";
        iframe.onload = function() {
            window.location = alt;
        }
        iframe.src = alt;
        document.body.appendChild(iframe);
    };

    var getParameterByName = function(name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }

    document.title = getParameterByName('title');
    var useBitcoin = getParameterByName('useBitcoin') == 'true';
    var useAlipay  = getParameterByName('useAlipay') == 'true';

    var price = getParameterByName('price');
    if (!price) price = 4800;

    var currency = getParameterByName('currency');

    var desc = getParameterByName('description');

    var handler = StripeCheckout.configure({
        key: getParameterByName('key'),
        image: 'https://s3.amazonaws.com/lantern-android/img/lantern_logo.svg',
        bitcoin: useBitcoin,
        currency: currency,
        description: desc,
        locale: 'auto',
        alipay: useAlipay,
        token: function(token) {
            var args = {
                stripeToken: token.id,
                stripeEmail: token.email
            };
            // on successful payment, redirect user
            // back to Lantern Pro app
            var url = 'lantern://pro?' + $.param(args);
            var g_intent = "scheme=lantern;package=org.getlantern.lantern;end";

            window.location = url;

        }
    });
    handler.open({
        name: 'Lantern',
        amount: parseInt(price)
    });
})();

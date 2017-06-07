# 海康萤石的phonegap/cordova 插件


## Using

Create a new Cordova Project

    $ cordova create hello com.example.helloapp Hello

Install the plugin

    $ cd hello
    $ cordova plugin add https://github.com/plotozhu/cordova-plugin-ezviz.git --variable APPKEY="YOUR APPKEY FROM open.ys7.com"


I have embedded ezviz sdk's demo as the ui activities. the source and gradle file are included in ezsdk.

apis:
   listcamera: 

Edit `www/js/index.js` and add the following code inside `onDeviceReady`

```js
    var success = function(message) {
        alert(message);
    }

    var failure = function() {
        alert("Error calling Hello Plugin");
    }

    hello.greet("World", success, failure);
```

Install iOS or Android platform

    cordova platform add ios
    cordova platform add android

Run the code

    cordova run

## More Info

For more information on setting up Cordova see [the documentation](http://cordova.apache.org/docs/en/latest/guide/cli/index.html)

For more info on plugins see the [Plugin Development Guide](http://cordova.apache.org/docs/en/latest/guide/hybrid/plugins/index.html)

For more info on how to add AAR file to cordova plugin, see [android - Cordova plugin development - adding aar - Stack Overflow](https://stackoverflow.com/questions/30757208/cordova-plugin-development-adding-aar)

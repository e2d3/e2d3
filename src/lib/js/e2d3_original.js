/**
* E2D3 ver. 0.2 is developed by E2D3 Project Members.
* Especially, all files in this repository are coded by engineers described below.
* However, all rights of all codes are reserved by Yasunobu Igarashi to realize a rapid management.
* And we released E2D3 ver. 0.2 under GNU AFFERO GENERAL PUBLIC LICENSE, Version 3.
* Lisence and Readme file see https://github.com/hipsrinoky/E2D3
* -- 
* Ver 0.2.2
* Lastest update 2014/11/07  Modified by Yu Yamamoto
*/
var e2d3 = (function () {
    'use strict';

    var e2d3 = {};
    /**
    * Initialize 
    *     Must call this function in page. if you need some action, you can callback function.
    */
    e2d3.initialize = function (_callback) {
        Office.initialize = function (reason) {
            if (_callback) callback(reason);
        };
    };
    /**
    * Set bind data
    * @args object          : [Required] {
    *           id(text)          : unique binding id ( if undifined set count of all binds)
    *           is_prompt(0 | 1)  : 1, show SELECT UI  
    *                               0, not show. shoud be selected cells.
    *        }
    * @callback function    : [Required] if succeeded binding, run callback.
    */
    e2d3.setBindData = function (args, callback) {
        if (!args.id) {
            Office.context.document.bindings.getAllAsync(function (result) {
                args.id = (!result.value) ? 0 : result.value++;
                set(args);
            });
        } else {
            set(args);
        }
        function set(a) {
            console.log('setBindData: bindId = ' + a.id);
            if (a.is_prompt) {
                Office.context.document.bindings.addFromPromptAsync(
                Office.BindingType.Matrix,
                a,
                function (result) {
                    if (result.status === Office.AsyncResultStatus.Succeeded) {
                        return callback(result.value);
                    } else {
                        if (result.error) {
                            showError('setBindData Error: ' + result.error.name + ':' + result.error.message, 'danger');
                        }
                        return callback(false);
                    }
                });
            } else {
                Office.context.document.bindings.addFromSelectionAsync(
                Office.BindingType.Matrix,
                a,
                function (result) {
                    if (result.status === Office.AsyncResultStatus.Succeeded) {
                        return callback(result.value);
                    } else {
                        if (result.error) {
                            showError('setBindData Error: ' + result.error.name + ':' + result.error.message, 'danger');
                        }
                        return callback(false);
                    }
                });
            }
        }
    };
    /**
    * Get bind by id
    *   do not use
    */
    e2d3.getBindDataById = function (id, callback) {

    };
    /**
    * get all bind
    */
    e2d3.getAllBindData = function (callback) {
        Office.context.document.bindings.getAllAsync(
             function (result) {
                 if (result.status === Office.AsyncResultStatus.Succeeded) {
                     return callback(result.value);
                 } else {
                     if (result.error) {
                         showError('Error: ' + result.error.name + ':' + result.error.message, 'danger');
                     }
                 }
             });
    };
    /**
    * add change method
    */
    e2d3.addChangeEvent = function (binding, _callback) {
        binding.addHandlerAsync(Office.EventType.BindingDataChanged, function (result) { 
            var response;
            if (result.binding.id) {
                response = true;
            } else {
                response = false;
            }
            if (_callback) _callback(response);
        });
    };
    /**
    * Excel To Json
    * @bindId               : [Required] target bind id.
    * @args object          : [Required] {
    *           dimension(1d|2d|3d) : format of data matrix. see documents.
    *        }
    * @callback function    : [Required] if succeeded conversion, return converted json data in callback function.
    */
    e2d3.bind2Json = function (bindId, args, callback) {
        console.log('bind2Json: bindId = ' + bindId);
        console.log('bind2Json: dimension = ' + args.dimension);
        var valueFormtat;
        valueFormtat = (args.is_formatted) ? Office.ValueFormat.Formatted :  Office.ValueFormat.Unformatted;
        
        Office.context.document.bindings.getByIdAsync(bindId, function (result) {
            if (result.status === Office.AsyncResultStatus.Succeeded) {
                
                result.value.getDataAsync(
                { valueFormat: valueFormtat },
                function (result) {

                    if (args.dimension === '1d') {
                        var arr = new Array();
                        var header = new Array();
                        var data = new Array();
                        for (var i = 0; i <= result.value.length; i++) {
                            if (result.value[i]) {
                                arr[i] = result.value[i][0];
                            }
                        }
                        if (!String(arr[0]).match(/\d+/)) {
                            for (var i = 0; i <= arr.length; i++) {
                                console.log('bind2json: 1d dimension loop i(not num) = ' + i);
                                if (i != 0) {
                                    console.log('bind2json: i is not num');
                                    data[arr[0]][i - 1] = arr[i];
                                }
                                console.log('data => ');
                                console.log(data);
                                return callback(data);
                            }
                        } else {
                            return callback(arr);
                        }
                    } else if (args.dimension == '2d') {
                        var arr = result.value;
                        console.log('bind2json: 2D dimension before value.length = ' + arr.length + ', value = ' + arr);

                        //var head = new Object;
                        //var text = '[';
                        //arr.map(function (d, i) {

                        //    //console.log(text);
                        //    if (i == 0) {
                        //        head = d;
                        //    } else {
                        //        text += "{";
                        //        var value = new Array();
                        //        d.map(function (v, j) {
                        //            value[j] = '"' + head[j] + '":"' + v + '"';
                        //        });
                        //        text += value.join(",") + "}";

                        //        if (i < arr.length - 1) {
                        //            text += ",";
                        //        }
                        //    }
                        //});
                        var head = arr[0];
                        var data = [];
                        arr.slice(1).forEach(function (d) {
                            var tmp = {};
                            head.forEach(function (dd, i) {
                                tmp[dd] = d[i];
                            });
                            data.push(tmp);
                        });
                        //text += "]";
                        //var data = JSON.parse(text);
                        console.log('bind2json: 2D dimension data.length = ' + data.length + ', data = ' + data);
                        return callback(data);
                    } else if (args.dimension == '3d') {
                        var arr = result.value;
                        var head = arr[0];
                        var data = {};
                        arr.slice(1).forEach(function (d) {
                            var tmp = {};
                            head.forEach(function (dd,i) {
                                tmp[dd] = d[i];
                            });
                            data[d[0]] = tmp;
                        });
                        return callback(data);
                    } else {
                        //nomal array
                        return callback(result.value);

                    }
                });
            } else {
                if (result.error) {
                    showError('bind2Json Error: ' + result.error.name + ':' + result.error.message, 'danger');
                }
                callback(false);
            }

        });

    };

    /**
    * Office style json set cells.
    * @json                 : [Required] target json that is simple array like "[[a,b,c],[x,y,z]...]"
    * @callback function    : [Required] if succeeded conversion and set data at cells, return binding object in callback.
    * 
    * *Caution : This function convert json AND set data to cells. Return boolean.
    */
    e2d3.json2Excel = function (json, callback) {
        //console.log('json2Excel: json = ' + json);
        Office.context.document.setSelectedDataAsync(json,
            { coercionType: Office.CoercionType.Matrix },
            function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    return callback(true);
                } else {
                    if (result.error) {
                        showError('Error: ' + result.error.name + ':' + result.error.message, 'danger');
                    }
                    callback(false);
                }
            });
    };
    /**
    * Multi dimension json set cells.
    * @json                 : [Required] target json that is multi dimensional object. specify format in args parameter.
    * @args object          : [Required] {
    *           dimension(1d|2d|3d) : format of data matrix. see documents.
    *        }
    * @callback function    : [Required] if succeeded conversion and set data at cells, return binding object in callback.
    * 
    * *Caution : This function convert json AND set data to cells. Return boolean.
    */
    e2d3.trimmedJson2Excel = function (json, args, callback) {

        var data = new Array();
        if (!Array.isArray(json)) {
            if (args.dimension === '1d') {
                //for (var i = 0; i <= json.length; i++) {
                //    if (json[i]) data[i] = [json[i]];
                //}
            } else if (args.dimension === '2d') {
                var c = 1;
                json.forEach(function (d, i) {
                    var r = [];
                    if (i == 0) {
                        //make header
                        var h = [], hc = 0;
                        for (var j in d) if (d.hasOwnProperty(j)) {
                            h[hc] = j; r[hc] = d[j];
                            hc++;
                        }
                        data[0] = h;
                        data[c] = r;
                    } else {
                        var rc = 0;
                        for (var j in d)  if (d.hasOwnProperty(j)) {
                            r[rc] = d[j];
                            rc++;
                        }
                        data[c] = r;
                    }
                    c++;
                });
            } else if (args.dimension === '3d') {
                
            }
        }
       
        console.log('trimedJson2Excel: data = ' + data);
        var response;
        if (data.length > 0) {
            Office.context.document.setSelectedDataAsync(data,
            function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    response = true;
                } else {
                    if (result.error) {
                        showError('Error: ' + result.error.name + ':' + result.error.message, 'danger');
                    }
                    response = false;
                }
            });
        } else {
            showError('Posted data not available.', 'danger');
            response = false;
        }
        callback(response);
        
    };
    /**
    * Release Binding Data By id
    **/
    e2d3.releaseBindDataById = function (args, callback) {
        if (!args.id) {
            return false;
        }
        if (args.isDataDelete) {
            Office.context.document.bindings.getByIdAsync(args.id, function (resultGet) {
                if (resultGet.status === Office.AsyncResultStatus.Succeeded) {
                    var binding = resultGet.value; // include row and col count
                    //Don't use removeHandlerAsync. Because "Office.EventType.BindingDataChanged" parameter is faild.
                    //remove change handler
                    //Office.select("bindings#" + args.id).removeHandlerAsync();
                    //binding.removeHandlerAsync(Office.EventType.BindingDataChanged, function (resultChange) {
                    //    if (resultChange.status === Office.AsyncResultStatus.Succeeded) {
                    //        createData(args, binding);
                    //    } else {
                    //        showError(resultChange.error.name + resultChange.error.message, 'error');
                    //    }

                    //});
                    createData(args, binding);
                } else {
                    if (resultGet.error) {
                        //showError(resultGet.error.name + resultGet.error.message, 'danger');
                    }
                    deleteData(args);
                }

            });
        } else {
            deleteData(args);
        }
        /**
        * Create "" value array.
        */
        function createData(args, binding) {
            var data = [];
            for (var i = 0; i <= binding.rowCount - 1; i++) {
                var col = [];
                for (var j = 0; j <= binding.columnCount - 1; j++) {
                    col[j] = '';
                }
                data[i] = col;
            }
            console.log(data);
            Office.context.document.setSelectedDataAsync(data,
                function (result) {
                    if (result.status === Office.AsyncResultStatus.Succeeded) {

                    } else {
                        if (result.error) {
                            //showError('Error: ' + result.error.name + ':' + result.error.message, 'danger');
                        }
                    }
                });
            deleteData(args);
        }
        /**
        * Set "" value data.
        */
        function deleteData(args) {
            Office.context.document.bindings.releaseByIdAsync(args.id, function (result) {
                if (result.status === Office.AsyncResultStatus.Succeeded) {
                    callback(true);
                } else {
                    if (result.error) {
                        //showError('Error: ' + result.error.name + ':' + result.error.message, 'danger');
                    }
                    callback(false);
                }
            });
        }
    };

    return e2d3;
})();

/**
* For Debug. Show objects
* * Caution! Need jQuery.
*/
function showObj(obj, s) {

    var _box;
    if (!_box) {
        _box = $("body");
    }
    if (!s) s = 0;

    var row = 0;
    $(obj).each(function (i) {
        //if (s == 0) {
        //    console.log(this);
        //}
        console.log(this);
        $(_box).append($("<div></div>").html("[" + row + "] <strong>" + i + "</strong> = " + this).css("margin-left", function () { return (s * 10) + 'px' }));

        row++;
    });
}
/**
* For Debug. Show objects
* Caution! Need jQuery.
*/
function showError(message, _type) {
    console.log(message);
    if (!_type) {
        _type = 'info';
    }
    var alert = $("<div>").addClass('e2d3-alert p6 alert alert-' + _type).html(message).hide();
    $("<body>").prepend(alert);

    $(alert).fadeIn(400, function () {
        $(alert).delay(2000).fadeOut(600, function () {
            $(alert).remove();
        });
    });
}

function lookdeep(object) {
    var collection = [], index = 0, next, item;
    for (item in object) {
        if (object.hasOwnProperty(item)) {
            next = object[item];
            if (typeof next == 'object' && next != null) {
                collection[index++] = item +
                ':{ ' + lookdeep(next).join(', ') + '}';
            }
            else collection[index++] = [item + ':' + String(next)];
        }
    }
    return collection;
}
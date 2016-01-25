/**
 * Created by elvin on 7/21/14.
 */

(function () {

    function fillRegionOptions() {
        getCities($('#_current_province').val());
        changeEvents();
    }

    function changeEvents() {
        $('#product_province_code').change(function () {
            getCities($(this).val());
        });
    }

    function getCities(provinceCode) {
 
        if (provinceCode == '' || provinceCode == undefined) {
            $('#product_city_code').html('<option value="">请选择</option>');
            return;
        }

        $.ajax({
            url: '/backstage/regions',
            type: 'get',
            data: {province_code: provinceCode},
            success: function (resp) {
                if (resp.result) {
                    var currentCityCode = $('#_current_city').val(),
                        options = '<option value="">请选择</option>';
                    for (var k in resp.result) {
                        options += '<option value="' + k + '"';
                        if (currentCityCode == k) options += ' selected="selected"';
                        options += '>' + resp.result[k] + '</option>'
                    }
                    $('#product_city_code').html(options).change();
                }
            },
            error: function () {

            }
        });
    }


    $(document).ready(function () {
        setTimeout(function () {
            fillRegionOptions();
        }, 500);
    });

})();

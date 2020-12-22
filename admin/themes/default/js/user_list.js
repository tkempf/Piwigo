 const color_icons = ["icon-red", "icon-blue", "icon-yellow", "icon-purple", "icon-green"];
const status_arr = ['webmaster', 'admin', 'normal', 'generic', 'guest'];
const level_arr = ['0', '1', '2', '4', '8'];
let current_users = [];
let guest_id = 0;
let guest_user = {};
let connected_user = 0;
let groups_arr = [];
let nb_days = '';
let nb_photos_per_page = '';
let last_user_index = -1;
let last_user_id = -1;
let pwg_token = '';
let selection = [];
/*----------------
Escape of pop-in
----------------*/

//get out of pop in via escape key
$(document).on('keydown', function (e) {
    if ( e.keyCode === 27) { // ESC button
        $("#UserList").fadeOut();
    }
});

//get out of pop in via clicking outside pop in
//$(document).on('click', function (e) {
//    console.log($(e.target));
//    if ($(e.target) && $(e.target).closest(".UserListPopInContainer").length === 0) {
//        $("#UserList").fadeOut();
//    }
//});

/*----------------
Group Selectize
----------------*/

jQuery('[data-selectize=groups]').selectize({
    valueField: 'value',
    labelField: 'label',
    searchField: ['label'],
    plugins: ['remove_button']
});

let groupSelectize = jQuery('[data-selectize=groups]')[0].selectize;
let groupGuestSelectize = jQuery('[data-selectize=groups]')[1].selectize;

/*-----------------
OnClick functions
-----------------*/
function open_user_list() {
    $("#UserList").fadeIn();
}

function close_user_list() {
    $("#UserList").fadeOut();
}

function open_guest_user_list() {
    $("#GuestUserList").fadeIn();
}

function close_guest_user_list() {
    $("#GuestUserList").fadeOut();
}

$( document ).ready(function() {
    $('.edit-password').click(function () {
        $('.user-property-password').hide();
        $('.user-property-password-change').show().css('display', 'flex');
    })

    $('.edit-password-cancel').click(function () {
      //possibly reset input value
        $('.user-property-password').show();
        $('.user-property-password-change').hide();
    })

    $('.edit-username').click(function () {
        $('.user-property-username').hide();
        $('.user-property-username-change').show().css('display', 'flex');
    })

    $('.edit-username-cancel').click(function () {
        //possibly reset input value
        $('.user-property-username').show();
        $('.user-property-username-change').hide();
    })

    $('#UserList .close-update-button').click(close_user_list);
    $('.CloseUserList').click(close_user_list);

    $("#toggleSelectionMode").attr("checked", false);
    $("#toggleSelectionMode").click(function () {
        let isSelection = $(this).is(":checked");
        selectionMode($(this).is(":checked"));
    });
    
    $('.edit-guest-user-button').click(open_guest_user_list);
    $('.CloseGuestUserList').click(close_guest_user_list);
    $('#GuestUserList .close-update-button').click(close_guest_user_list);

    $("#show_password").click(function() {
        if ($(this).hasClass("icon-eye")) {
            $(this).removeClass("icon-eye");
            $(this).addClass("icon-eye-off");
            $("#AddUserPassword").get(0).type = "text";
            $(this).html("Hide")
        } else {
            $(this).removeClass("icon-eye-off");
            $(this).addClass("icon-eye");
            $("#AddUserPassword").get(0).type = "password";
            $(this).html("Show")
        }
    })
    /* Action */
    jQuery("[id^=action_]").hide();

    jQuery("select[name=selectAction]").change(function () {
        jQuery("#applyActionBlock .infos").hide();
        jQuery("[id^=action_]").hide();
        jQuery("#action_"+$(this).prop("value")).show();
        if (jQuery(this).val() != -1) {
            jQuery("#applyActionBlock").show();
        } else {
            jQuery("#applyActionBlock").hide();
        }
    });
    jQuery("#applyAction").click(function() {
        let action = jQuery("select[name=selectAction]").prop("value");
        let method = 'pwg.users.setInfo';
        let data = {
            pwg_token: pwg_token,
            user_id: selection.map(x => x.id)
        };
        switch (action) {
            case 'delete':
                if (!($("#permitActionUserList .user-list-checkbox[name=confirm_deletion]").attr("data-selected") === "1")) {
                    alert(missingConfirm);
                    return false;
                }
                method = 'pwg.users.delete';
                break;
            case 'group_associate':
                method = 'pwg.groups.addUser';
                data.group_id = jQuery("#permitActionUserList select[name=associate]").prop("value");
                break;
            case 'group_dissociate':
                method = 'pwg.groups.deleteUser';
                data.group_id = jQuery("#permitActionUserList select[name=dissociate]").prop("value");
                break;
            case 'status':
                data.status = jQuery("#permitActionUserList select[name=status]").prop("value");
                break;
            case 'enabled_high':
                data.enabled_high = $("#permitActionUserList .user-list-checkbox[name=enabled_high_yes]").attr("data-selected") === "1" ? true : false;
                break;
            case 'level':
                data.level = jQuery("#permitActionUserList select[name=level]").val();
                break;
            case 'nb_image_page':
                data.nb_image_page = jQuery("#permitActionUserList input[name=nb_image_page]").val();
                break;
            case 'theme':
                data.theme = jQuery("#permitActionUserList select[name=theme]").val();
                break;
            case 'language':
                data.language = jQuery("#permitActionUserList select[name=language]").val();
                break;
            case 'recent_period':
                data.recent_period = recent_period_values[$('#permitActionUserList .period-select-bar .select-bar-container').slider("option", "value")];;
                break;
            case 'expand':
                data.expand = $("#permitActionUserList .user-list-checkbox[name=expand_yes]").attr("data-selected") === "1" ? true : false;
                break;
            case 'show_nb_comments':
                data.show_nb_comments = $("#permitActionUserList .user-list-checkbox[name=show_nb_comments_yes]").attr("data-selected") === "1" ? true : false
                break;
            case 'show_nb_hits':
                data.show_nb_hits = $("#permitActionUserList .user-list-checkbox[name=show_nb_hits_yes]").attr("data-selected") === "1" ? true : false;
                break;
            default:
                alert("Unexpected action");
                return false;
        }
        jQuery.ajax({
            url: "ws.php?format=json&method="+method,
            type:"POST",
            data: data,
            beforeSend: function() {
                jQuery("#applyActionLoading").show();
            },
            success:function(data) {
                jQuery("#applyActionLoading").hide();
                jQuery("#applyActionBlock .infos").show();
                update_user_list();
                if (action == 'delete') {
                    selection = [];
                    update_selection_content();
                }
            },
            error:function(XMLHttpRequest, textStatus, errorThrows) {
                jQuery("#applyActionLoading").hide();
            }
        });
        return false;
    });

    $(".yes_no_radio .user-list-checkbox").unbind("click").click(function () {
        if ($(this).attr("data-selected") === "1") {
            $(this).attr("data-selected", "0");
            $(this).siblings().attr("data-selected", "1");
        } else {
            $(this).attr("data-selected", "1");
            $(this).siblings().attr("data-selected", "0");
        }
    })
    $(".AddUserGenPassword").click(gen_password);
    $('.AddUserSubmit').click(add_user);
    $('.AddUserCancel').click(add_user_close);
    $(".CloseAddUser").click(add_user_close);   


    //open add user pop in
    $('.add-user-button').click(add_user_open);

    /* Select */

    jQuery("#selectSet").click(function () {
        select_whole_set();
        return false;
    });


    jQuery("#selectAllPage").click(function () {
        let selection_ids = selection.map(x => x.id);
        for (let i = 0; i < current_users.length; i++) {
            if (!selection_ids.includes(current_users[i].id)) {
                selection.push({id: current_users[i].id, username: current_users[i].username});
            }
        }
        update_selection_content();
        return false;
    });

    jQuery("#selectNone").click(function () {
        selection = [];
        update_selection_content();
        return false;
    });

    jQuery("#selectInvert").click(function () {
        let selection_ids = selection.map(x => x.id);
        for (let i = 0; i < current_users.length; i++) {
            if (selection_ids.includes(current_users[i].id)) {
                selection.splice(selection.findIndex((x) => x.id == current_users[i].id), 1);
            } else {
                selection.push({id: current_users[i].id, username: current_users[i].username});
            }
        }
        update_selection_content();
        return false;
    });

    $("#permitActionUserList select[name=selectAction]").val("-1");

    $("#advanced_filter_button").click(advanced_filter_button_click);
    $("#advanced-filter-container span.icon-cancel").click(advanced_filter_hide);
    $(".advanced-filter-select").change(update_user_list);
    $("#user_search").on("input", update_user_list);
});


/*----------------
Checkboxes
----------------*/

function checkbox_change() {
    if ($(this).attr('data-selected') == '1') {
        $(this).find("i").hide();
    } else {
        $(this).find("i").show();
    }
}

function checkbox_click() {
    if ($(this).attr('data-selected') == '1') {
        $(this).attr('data-selected', '0');
        $(this).find("i").hide();
    } else {
        $(this).attr('data-selected', '1');
        $(this).find("i").show();
    }
}

$('.user-list-checkbox').unbind("change").change(checkbox_change);
$('.user-list-checkbox').unbind("click").click(checkbox_click);

/* ---------------
User edit sliders 
----------------*/
const nb_image_page_values = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,35,40,45,50,60,70,80,90,100,200,300,500,999];
const recent_period_values = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30,40,50,60,80,99];
const recent_period_init = 0;
//const recent_period_init = getSliderKeyFromValue($('.period-select-bar input[name=recent_period]').val(), recent_period_values);
const nb_image_page_init = 0;
//const nb_image_page_init = getSliderKeyFromValue($('.photos-select-bar input[name=nb_image_page]').val(), nb_image_page_values);

/**
* find the key from a value in the startStopValues array
*/
function getSliderKeyFromValue(value, values) {
    for (var key in values) {
        if (values[key] >= value) {
            return key;
        }
    }
    return 0;
}

function getNbImagePageInfoFromIdx(idx) {
    return sprintf(
        "%d",
        nb_image_page_values[idx]
    );
}

function getRecentPeriodInfoFromIdx(idx) {
    return recent_period_values[idx].toString();
}

/* Photos bar slider */
jQuery('#UserList .photos-select-bar .select-bar-container').slider({
    range: "min",
    min: 0,
    max: nb_image_page_values.length - 1,
    value: nb_image_page_init,
    change: function( event, ui ) {
        $('#UserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(ui.value));
    },
    slide: function( event, ui ) {
        $('#UserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(ui.value));
    },
    stop: function( event, ui ) {
        $('#UserList .photos-select-bar input[name=nb_image_page]').val(nb_image_page_values[ui.value]).trigger('change');
    }
});


jQuery('#GuestUserList .photos-select-bar .select-bar-container').slider({
    range: "min",
    min: 0,
    max: nb_image_page_values.length - 1,
    value: nb_image_page_init,
    change: function( event, ui ) {
        $('#GuestUserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(ui.value));
    },
    slide: function( event, ui ) {
        $('#GuestUserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(ui.value));
    },
    stop: function( event, ui ) {
        $('#GuestUserList .photos-select-bar input[name=nb_image_page]').val(nb_image_page_values[ui.value]).trigger('change');
    }
});

$('#permitActionUserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(0));
jQuery('#permitActionUserList .photos-select-bar .select-bar-container').slider({
    range: "min",
    min: 0,
    max: nb_image_page_values.length - 1,
    value: nb_image_page_init,
    change: function( event, ui ) {
        $('#permitActionUserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(ui.value));
    },
    slide: function( event, ui ) {
        $('#permitActionUserList .photos-select-bar .nb-img-page-infos').html(getNbImagePageInfoFromIdx(ui.value));
    },
    stop: function( event, ui ) {
        $('#permitActionUserList .photos-select-bar input[name=nb_image_page]').val(nb_image_page_values[ui.value]).trigger('change');
    }
});

/* recent_period slider */
$('#UserList .period-select-bar .select-bar-container').slider({
    range: "min",
    min: 0,
    max: recent_period_values.length - 1,
    value: recent_period_init,
    change: function( event, ui ) {
        $('#UserList .period-select-bar .recent_period_infos').html(getRecentPeriodInfoFromIdx(ui.value));
    },
    slide: function( event, ui ) {
        $('#UserList .period-select-bar .recent_period_infos').html(getRecentPeriodInfoFromIdx(ui.value));
    },
    stop: function( event, ui ) {
        $('#UserList .period-select-bar input[name=recent_period]').val(recent_period_values[ui.value]).trigger('change');
    }
});

$('#GuestUserList .period-select-bar .select-bar-container').slider({
    range: "min",
    min: 0,
    max: recent_period_values.length - 1,
    value: recent_period_init,
    change: function( event, ui ) {
        $('#GuestUserList .period-select-bar .recent_period_infos').html(getRecentPeriodInfoFromIdx(ui.value));
    },
    slide: function( event, ui ) {
        $('#GuestUserList .period-select-bar .recent_period_infos').html(getRecentPeriodInfoFromIdx(ui.value));
    },
    stop: function( event, ui ) {
        $('#GuestUserList .period-select-bar input[name=recent_period]').val(recent_period_values[ui.value]).trigger('change');
    }
});

$('#permitActionUserList .period-select-bar .select-bar-container').slider({
    range: "min",
    min: 0,
    max: recent_period_values.length - 1,
    value: recent_period_init,
    change: function( event, ui ) {
        $('#permitActionUserList .period-select-bar .recent_period_infos').html(getRecentPeriodInfoFromIdx(ui.value));
    },
    slide: function( event, ui ) {
        $('#permitActionUserList .period-select-bar .recent_period_infos').html(getRecentPeriodInfoFromIdx(ui.value));
    },
    stop: function( event, ui ) {
        $('#permitActionUserList .period-select-bar input[name=recent_period]').val(recent_period_values[ui.value]).trigger('change');
    }
});
$('#permitActionUserList .photos-select-bar .select-bar-container').slider("option", "value", 0);
let period_info = getRecentPeriodInfoFromIdx(0);
$('#permitActionUserList .period-select-bar .recent_period_infos').html(period_info);


/* -----------
Pagination
------------*/
let per_page = 5;
let actual_page = 1;
let max_page = 1;
let nb_filtered_users = 0;
const page_ellipsis = '<span>...</span>'
const page_item = '<a data-page="%d">%d</a>';
let promise_pending = false;
let update_ask = false;

function move_to_page(page) {
    if (page < 1 || page > max_page)
        return;
    actual_page = page;
    update_pagination_menu();
    update_user_list();
}

$('.pagination-arrow.rigth').on('click', () => {
    move_to_page(actual_page + 1);
})

$('.pagination-arrow.left').on('click', () => {
    move_to_page(actual_page - 1);
})

$('.pagination-per-page a').on('click',function () {
    per_page = parseInt($(this).html());
    actual_page = 1;
    update_pagination_menu();
    update_user_list();
});

function append_pagination_item(page = null) {
    if (page != null) {
        let new_tag = $(page_item.replace(/%d/g, page));
        $('.pagination-item-container').append(new_tag);
        if (actual_page == page) {
            new_tag.addClass('actual');
        }
        new_tag.on('click', () => {
            move_to_page(new_tag.data('page'));
        })
    } else {
        $('.pagination-item-container').append($(page_ellipsis));
    }
}

function update_pagination_items() {
    $('.pagination-item-container a').remove();
    $('.pagination-item-container span').remove();

    append_pagination_item(1);

    if (actual_page > 2) {
        append_pagination_item();
    }
    if (actual_page != 1 && actual_page != max_page) {
        append_pagination_item(actual_page)
    }
    if (actual_page < (max_page - 1)) {
        append_pagination_item();
    }   
    append_pagination_item(max_page);

}

function update_pagination_menu() {
    max_page = Math.ceil(nb_filtered_users / per_page);
    updateArrows();
    update_pagination_items();
    if (max_page <= 1) {
        $('.pagination-container').hide();
    } else {
        $('.pagination-container').show();
    }
}

function updateArrows() {
    if (actual_page == 1) {
        $('.pagination-arrow.left').addClass('unavailable');
    } else {
        $('.pagination-arrow.left').removeClass('unavailable');
    }   
    if (actual_page == max_page) {
        $('.pagination-arrow.rigth').addClass('unavailable');
    } else {
        $('.pagination-arrow.rigth').removeClass('unavailable');
    }
}

/*------------------
Advanced filter
------------------*/

function advanced_filter_button_click() {
    if ($("#advanced-filter-container").css("display") === "none") {
        advanced_filter_show();
    } else {
        advanced_filter_hide();
    }
}

function advanced_filter_show() {
    $("#advanced-filter-container").show();
    update_user_list();
}

function advanced_filter_hide() {
    $("#advanced-filter-container").hide();
    update_user_list();
}

const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function getDateStr(date) {
    let date_arr = date.split(' ');
    let curr_month = months[parseInt(date_arr[0]) - 1];
    return curr_month + " " + date_arr[1]
}

function setupRegisterDates(register_dates) {
    $('#advanced-filter-container .dates-select-bar .select-bar-container').slider({
        range: true,
        min: 0,
        max: register_dates.length - 1,
        value: [0, 0],
        change: function( event, ui ) {
            $('#advanced-filter-container .dates-select-bar .dates_info_min').html("MIN : " + getDateStr(register_dates[ui.values[0]]));
            $('#advanced-filter-container .dates-select-bar .dates_info_max').html("MAX : " + getDateStr(register_dates[ui.values[1]]));
        },
        slide: function( event, ui ) {
            $('#advanced-filter-container .dates-select-bar .dates_info_min').html("MIN : " + getDateStr(register_dates[ui.values[0]]));
            $('#advanced-filter-container .dates-select-bar .dates_info_max').html("MAX : " + getDateStr(register_dates[ui.values[1]]));
        },
        stop: function( event, ui ) {
            update_user_list();
            $('#advanced-filter-container .period-select-bar').val(register_dates[ui.values[0]]);
        }
    });
}

$('#advanced-filter-container .dates-select-bar .select-bar-container').slider("option", "values", [0, register_dates.length - 1]);
/*------------------
Add User
------------------*/

function gen_password(e) {
    e.preventDefault();

    var characterSet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';

    var i;
    var password;
    var length = getRandomInt(8, 15);

    password = '';
    for (i = 0; i < length; i++) {
      password += characterSet.charAt(Math.floor(Math.random() * characterSet.length));
    }

    jQuery(".AddUserLabelPassword .AddUserInput").val(password);
}

function add_user_close() {
    $("#AddUser").fadeOut();
}

function add_user_open() {
    $('#AddUser .AddUserInput').val('');
    $("#AddUser").fadeIn();
}

/*------------------
Selection mode
------------------*/

function checkbox_container_change() {
    if ($(this).attr('data-selected') == '1') {
        $(this).attr('data-selected', '0');
        $(this).find("i").hide();
    } else {
        $(this).attr('data-selected', '1');
        $(this).find("i").show();
    }
}

function checkbox_container_click() {
    let curr_container = $(this).closest(".user-container");
    let in_container = curr_container.length != 0;
    let curr_user = in_container ? current_users[parseInt(curr_container.attr("key"))] : {id: -1};
    if ($(this).attr('data-selected') == '1') {
        $(this).attr('data-selected', '0');
        $(this).find("i").hide();
        if (in_container) {
            curr_container.removeClass("container-selected");
            selection = selection.filter((elem) => elem.id != curr_user.id);
        }
    } else {
        $(this).attr('data-selected', '1');
        $(this).find("i").show();
        if (in_container) {
            curr_container.addClass("container-selected");
            selection.push({id: curr_user.id, username: curr_user.username})
        }
    }
    if (in_container) {
        update_selection_content();
    }
}

function create_user_selected_item(user) {
    let new_elem = $("#template .user-selected-item").clone();
    new_elem.attr("data-id", user.id.toString());
    new_elem.find("p").html(user.username);
    new_elem.find("a").click(() => {
        selection.splice(selection.findIndex((i) => i.id == user.id), 1);
        update_selection_content();
    })
    return new_elem;
}

function generate_user_selected_items() {
    let items_created = 0;
    let others = selection.length - 5;
    $('.user-selected-list .user-selected-item').remove();
    for (let i = 0; i < selection.length && items_created < 5; i++) {
        if (typeof selection[i].username !== 'undefined') {
            $('.user-selected-list').append(create_user_selected_item(selection[i])); 
            items_created += 1;
        }
    }
    if (others >= 1) {
        $(".selection-other-users").html(str_and_others_tags.replace('%s', others))
        $(".selection-other-users").show()
    } else {
        $(".selection-other-users").hide();
    }
    return
}

function fill_user_selected_list() {
    let elems_with_username = 0;
    for (let i = 0; i < selection.length && elems_with_username < 5;i++) {
        if (typeof selection[i].username !== 'undefined') {
            elems_with_username += 1;
        }
    }
    if (elems_with_username < 5 && elems_with_username != selection.length) {
        get_first_selection_usernames(generate_user_selected_items);
    } else {
        generate_user_selected_items();
    }
}

function update_selection_content() {
    number = selection.length;
    fill_user_selected_list();
    if (number == 0) {
        $("#forbidAction").show();
        $('.selection-mode-ul').hide();
        $("#permitActionUserList").hide();
    } else {
        $("#forbidAction").hide();
        $("#permitActionUserList").show();
        $('.selection-mode-ul').show();
    }
    set_selected_to_selection();
}

function set_selected_to_selection() {
    if (!$("#toggleSelectionMode").is(":checked")) {
        return
    }
    $(".user-container-wrapper .user-container").each(function (index) {
        selection_ids = selection.map(x => x.id);
        if (selection_ids.includes(current_users[index].id)) {
            $(this).addClass("container-selected");
            $(this).find(".user-list-checkbox").attr("data-selected", "1");
            $(this).find(".user-list-checkbox i").show();
        } else {
            $(this).removeClass("container-selected");
            $(this).find(".user-list-checkbox").attr("data-selected", "0");
            $(this).find(".user-list-checkbox i").hide();
        }
    })
}

function selectionMode(isSelection) {
    $("#permitActionUserList select[name=selectAction]").val("-1");
    $("#permitActionUserList select[name=selectAction]").trigger("change");
    if (isSelection) {
        set_selected_to_selection();
        $(".in-selection-mode").show();
        $(".not-in-selection-mode").hide();
    } else {
        $(".container-selected").removeClass("container-selected");
        $(".in-selection-mode").hide();
        $(".not-in-selection-mode").show();
    }
}


/*------------------
General functions
------------------*/

function get_group_name_from_id(id) {
    for (let i = 0; i < groups_arr.length; i++) {
        if (groups_arr[i][0] == id) {
            return (groups_arr[i][1]);
        }
    }
    return ("group_id error");
}

function get_container_index_from_uid(uid) {
    for (let i = 0; i < current_users.length; i++) {
        if (current_users[i].id == uid) {
            return i;
        }
    }
    return -1;
}

/*-----------------------
Generate User Containers
-----------------------*/
function generate_groups(container, groups) {
    container.find(".user-container-groups").html('');
    if (groups.length >= 1) {
        let primary_grp = $("#template .group-primary").clone();
        primary_grp.html(get_group_name_from_id(groups[0]));
        primary_grp.addClass(color_icons[groups[0] % 5]);
        container.find(".user-container-groups").append(primary_grp);
    }
    if (groups.length >= 2) {
        let primary_grp = $("#template .group-primary").clone();
        primary_grp.html(get_group_name_from_id(groups[1]));
        primary_grp.addClass(color_icons[groups[1] % 5]);
        container.find(".user-container-groups").append(primary_grp);
    }
    if (groups.length >= 3) {
        let bonus_grp = $("#template .group-bonus").clone();
        bonus_grp.html("...");
        bonus_grp.addClass(color_icons[groups[2] % 5]);
        container.find(".user-container-groups").append(bonus_grp);
    }
}

function get_initials(username) {
    let words = username.toUpperCase().split(" ");
    let res = words[0][0];

    if (words.length > 1) {
        res += words[1][0];
    }
    return res;
}

function fill_container_user_info(container, user_index) {
    let user = current_users[user_index];
    let registration_dates = user.registration_date.split(' ');
    container.attr('key', user_index);
    container.find(".user-container-username span").html(user.username);
    container.find(".user-container-initials span").html(get_initials(user.username)).addClass(color_icons[user.id % 5]);
    container.find(".user-container-status span").html(user.status);
    container.find(".user-container-email span").html(user.email);
    generate_groups(container, user.groups);
    container.find(".user-container-registration-date").html(registration_dates[0]);
    container.find(".user-container-registration-time").html(registration_dates[1]);
}  

function generate_user_list() {
    $("#user-table-content").find(".user-container").remove();
    for (let i = 0; i < current_users.length; i++) {
        let new_container = $("#template .user-container").clone();
        fill_container_user_info(new_container, i);
        $("#user-table-content .user-container-wrapper").append(new_container);
    }
    $('.user-container .user-list-checkbox').unbind("change").change(checkbox_change);
    $('.user-container .user-list-checkbox').unbind("click").click(checkbox_container_click);
}

/*---------------------
Fill the pop-in values
---------------------*/

function get_status_index(status) {
    for (let i = 0; i < status_arr.length; i++) {
        if (status_arr[i] === status) {
            return i;
        }
    }
    return 0;
}

function get_level_index(level) {
    for (let i = 0; i < level_arr.length; i++) {
        if (level_arr[i] === level) {
            return i;
        }
    }
    return 0;
}

function set_selected_groups(groups) {
    for (let i = 0; i < groupOptions.length; i++) {
        groupOptions[i].isSelected = groups.includes(groupOptions[i].value);
    }
}

function fill_user_edit_summary(user_to_edit, pop_in) {
    pop_in.find('.user-property-initials span').html(get_initials(user_to_edit.username)).removeClass(color_icons.join(' ')).addClass(color_icons[user_to_edit.id % 5]);
    pop_in.find('.user-property-username span:first').html(user_to_edit.username);
    if (user_to_edit.id === connected_user) {
        pop_in.find('.user-property-username .edit-username-specifier').show();
    } else {
        pop_in.find('.user-property-username .edit-username-specifier').hide();
    }
    pop_in.find('.user-property-username-change input').val(user_to_edit.username);
    pop_in.find('.user-property-password-change input').val('');
    pop_in.find('.user-property-permissions a').attr('href', `admin.php?page=user_perm&user_id=${user_to_edit.id}`);
    pop_in.find('.user-property-registered').html(user_to_edit.registration_date_string + ', ' + user_to_edit.registration_date_since);;
    pop_in.find('.user-property-last-visit').html(user_to_edit.last_visit_string + ', ' + user_to_edit.last_visit_since);
}

function fill_user_edit_properties(user_to_edit, pop_in) {
    let status_index = get_status_index(user_to_edit.status);
    let level_index = get_level_index(user_to_edit.level);
    let current_group_selectize = user_to_edit.id === guest_id ? groupGuestSelectize : groupSelectize;

    pop_in.find('.user-property-email input').val(user_to_edit.email);
    pop_in.find(`.user-property-status select option:eq(${status_index})`).prop("selected", true);
    pop_in.find(`.user-property-level select option:eq(${level_index})`).prop('selected', true);
    pop_in.find('.photos-select-bar input').val(user_to_edit.recent_period);
    set_selected_groups(user_to_edit.groups);
    current_group_selectize.clear();
    current_group_selectize.load(function(callback) {
        callback(groupOptions);
    });
    jQuery.each(jQuery.grep(groupOptions, function(group) {
        return group.isSelected;
    }), function(i, group) {
        current_group_selectize.addItem(group.value);
    });
    pop_in.find('.user-list-checkbox[name="hd_enabled"]').attr('data-selected', user_to_edit.enabled_high == 'true' ? '1' : '0');
}

function fill_user_edit_preferences(user_to_edit, pop_in) {
    let slider_key_photos = getSliderKeyFromValue(parseInt(user_to_edit.nb_image_page), nb_image_page_values);
    let slider_key_period = getSliderKeyFromValue(parseInt(user_to_edit.recent_period), recent_period_values);
    
    pop_in.find('.photos-select-bar .select-bar-container').slider("option", "value", slider_key_photos);
    pop_in.find('.user-property-theme select option').each(function () {
        if ($(this).val() == user_to_edit.theme) {
            $(this).prop('selected', true);
        }
    });
    pop_in.find('.user-property-lang select option').each(function () {
        if ($(this).val() == user_to_edit.language) {
            $(this).prop('selected', true);
        }
    });
    pop_in.find('.period-select-bar .select-bar-container').slider("option", "value", slider_key_period);
    pop_in.find('.user-list-checkbox[name="expand_all_albums"]').attr('data-selected', user_to_edit.expand == 'true' ? '1' : '0');
    pop_in.find('.user-list-checkbox[name="show_nb_comments"]').attr('data-selected', user_to_edit.show_nb_comments == 'true' ? '1' : '0');
    pop_in.find('.user-list-checkbox[name="show_nb_hits"]').attr('data-selected', user_to_edit.show_nb_hits == 'true' ? '1' : '0');   
}

function fill_user_edit_update(user_to_edit, pop_in) {
    pop_in.find('.update-user-button').unbind("click").click(
        user_to_edit.id === guest_id ? update_guest_info : update_user_info);
    pop_in.find('.edit-username-validate').unbind("click").click(update_user_username);
    pop_in.find('.edit-password-validate').unbind("click").click(update_user_password);
    pop_in.find('.delete-user-button').unbind("click").click(function () {
        $.confirm({
            title: title_msg.replace('%s', user_to_edit.username),
            buttons: {
                confirm: {
                    text: confirm_msg,
                    btnClass: 'btn-red',
                    action: function () {
                        delete_user(user_to_edit.id);
                    }
                },
                cancel: {
                    text: cancel_msg
                }
            },
            ...jConfirm_confirm_options
        });
    })
}

function fill_user_edit(user_to_edit) {
    let pop_in = $('.UserListPopInContainer');
    fill_user_edit_summary(user_to_edit, pop_in);
    fill_user_edit_properties(user_to_edit, pop_in);
    fill_user_edit_preferences(user_to_edit, pop_in);
    fill_user_edit_update(user_to_edit, pop_in);
}

function fill_guest_edit() {
    let user_to_edit = guest_user;
    let pop_in = $('.GuestUserListPopInContainer');
    fill_user_edit_summary(user_to_edit, pop_in);
    fill_user_edit_properties(user_to_edit, pop_in);
    fill_user_edit_preferences(user_to_edit, pop_in);
    fill_user_edit_update(user_to_edit, pop_in);
}

/*-------------------
Fill data for setInfo
-------------------*/

function fill_ajax_data_from_properties(ajax_data, pop_in) {
    let groups_selected = pop_in.find('.user-property-group .selectize-input .item').map(function () {
        return parseInt($(this).attr('data-value'));
    } ).get();
    console.log(groups_selected);
    ajax_data['email'] = pop_in.find('.user-property-email input').val();
    ajax_data['status'] = pop_in.find('.user-property-status select').val();
    ajax_data['level'] = pop_in.find('.user-property-level select').val();
    ajax_data['group_id'] = groups_selected.length == 0 ? -1 : groups_selected;
    ajax_data['enabled_high'] = pop_in.find('.user-list-checkbox[name="hd_enabled"]').attr('data-selected') == '1' ? true : false ;
    return ajax_data
}

function fill_ajax_data_from_preferences(ajax_data, pop_in) {
    ajax_data['theme'] = pop_in.find('.user-property-theme select').val();
    ajax_data['language'] = pop_in.find('.user-property-lang select').val();
    ajax_data['nb_image_page'] = nb_image_page_values[pop_in.find('.photos-select-bar .select-bar-container').slider("option", "value")];
    ajax_data['recent_period'] = recent_period_values[pop_in.find('.period-select-bar .select-bar-container').slider("option", "value")];
    ajax_data['expand'] = pop_in.find('.user-list-checkbox[name="expand_all_albums"]').attr('data-selected') == '1' ? true : false;
    ajax_data['show_nb_comments'] = pop_in.find('.user-list-checkbox[name="show_nb_comments"]').attr('data-selected') == '1' ? true : false ;
    ajax_data['show_nb_hits'] = pop_in.find('.user-list-checkbox[name="show_nb_hits"]').attr('data-selected') == '1' ? true : false ;
    return ajax_data
}

function fill_ajax_data_from_container(ajax_data, pop_in) {
    ajax_data = fill_ajax_data_from_properties(ajax_data, pop_in);
    ajax_data = fill_ajax_data_from_preferences(ajax_data, pop_in);
    return ajax_data
}

/*----------------
Ajax Requests
----------------*/

function get_first_selection_usernames(callback) {
    let first_ids = selection.slice(0, 50).map(x => x.id);
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.getList",
        type: "POST",
        data: {
            display: "username",
            order: "id",
            user_id: first_ids,
            exclude: [guest_id]
        },
        success:function(data) {
            data = jQuery.parseJSON(data);
            let result = data.result.users;
            for (let i = 0; i < result.length;i++) {
                let index = selection.findIndex(x => x.id === result[i].id);
                if (index != -1) {
                    selection[index].username = result[i].username;
                }
            }
            callback();
        }
    });
}

function select_whole_set() {
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.getList",
        type: "POST",
        data: {
            display: "only_id",
            order: "id",
            page: actual_page - 1,
            per_page: 0,
            exclude: [guest_id]
        },
        beforeSend: function() {
            $("#checkActions .loading").show();
        },
        success:function(data) {
            data = jQuery.parseJSON(data);
            selection = data.result.map((x) => {
                return {id: x};
            });
            $("#checkActions .loading").hide();
            update_selection_content();
        },
        error:function(XMLHttpRequest, textStatus, errorThrows) {
            $("#checkActions .loading").hide();
        }
    });
}

function update_user_username() {
    let pop_in_container = $('.UserListPopInContainer');
    let ajax_data = {
        pwg_token: pwg_token,
        user_id: last_user_id
    };
    ajax_data['username'] = pop_in_container.find('.user-property-input-username').val();
    if (ajax_data.username === '') {
        return;
    }
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.setInfo",
        type: "POST",
        data: ajax_data,
        success: (raw_data) => {
            data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                if (last_user_index != -1) {
                    current_users[last_user_index].username = data.result.users[0].username;
                    $('#UserList .user-property-username .edit-username-title').html(current_users[last_user_index].username);
                    $('#UserList .user-property-initials span').html(get_initials(current_users[last_user_index].username));
                    fill_container_user_info($('#user-table-content .user-container').eq(last_user_index), last_user_index);
                }
                $("#UserList .update-user-success").fadeIn();
                $('.user-property-username').show();
                $('.user-property-username-change').hide();
            }
        }
    })
}

function update_user_password() {
    let pop_in_container = $('.UserListPopInContainer');
    let ajax_data = {
        pwg_token: pwg_token,
        user_id: last_user_id
    };
    ajax_data['password'] = pop_in_container.find('.user-property-input-password').val();
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.setInfo",
        type: "POST",
        data: ajax_data,
        success: (raw_data) => {
            data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                $("#UserList .update-user-success").fadeIn();
                $('.user-property-password').show();
                $('.user-property-password-change').hide();
            }
        }
    })
}

function update_user_info() {
    let pop_in_container = $('.UserListPopInContainer');
    let ajax_data = {
        pwg_token: pwg_token,
        user_id: last_user_id
    };

    ajax_data = fill_ajax_data_from_container(ajax_data, pop_in_container);
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.setInfo",
        type: "POST",
        data: ajax_data,
        success: function(raw_data) {
            data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                let result_user = data.result.users[0];
                if (last_user_index != -1) {
                    current_users[last_user_index].email = result_user.email;
                    current_users[last_user_index].enabled_high = result_user.enabled_high;
                    current_users[last_user_index].expand = result_user.expand;
                    current_users[last_user_index].groups = result_user.groups;
                    current_users[last_user_index].language = result_user.language;
                    current_users[last_user_index].level = result_user.level;
                    current_users[last_user_index].nb_image_page = result_user.nb_image_page;
                    current_users[last_user_index].recent_period = result_user.recent_period;
                    current_users[last_user_index].show_nb_comments = result_user.show_nb_comments;
                    current_users[last_user_index].show_nb_hits = result_user.show_nb_hits;
                    current_users[last_user_index].status = result_user.status;
                    current_users[last_user_index].theme = result_user.theme;
                    fill_container_user_info($('#user-table-content .user-container').eq(last_user_index), last_user_index);
                }
                $("#UserList .update-user-success").fadeIn();
            }
        }
    });
}

function get_guest_info() {
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.getList",
        type: "POST",
        data: {
            display: "all",
            user_id: guest_id
        },
        success: (raw_data) => {
            data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                guest_user = data.result.users[0];
                fill_guest_edit();
            }
        }
    });
}

function get_user_info(uid, callback=None) {
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.getList",
        type: "POST",
        data: {
            display: "all",
            user_id: uid
        },
        success: (raw_data) => {
            data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                let result_user = data.result.users[0];
                fill_user_edit(result_user);
                callback();
            }
        }
    });
}

function update_guest_info() {
    let pop_in_container = $('.GuestUserListPopInContainer');
    let ajax_data = {
        pwg_token: pwg_token,
        user_id: guest_id
    };
    ajax_data = fill_ajax_data_from_container(ajax_data, pop_in_container);
    ajax_data.email = undefined;
    ajax_data.status = undefined;
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.setInfo",
        type: "POST",
        data: ajax_data,
        success: function(raw_data) {
            data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                $("#GuestUserList .update-user-success").fadeIn();
            }
        }
    });
}

function update_user_list() {
    let update_data = {
        display: "all",
        order: "id",
        page: actual_page - 1,
        per_page: per_page,
        exclude: [guest_id]
    }
    update_data["filter"] = "%" + $("#user_search").val() + "%";
    if ($("#advanced-filter-container").css("display") !== "none") {
        update_data["status"] = $(".advanced-filter-select[name=filter_status]").val();
        update_data["group_id"] = $(".advanced-filter-select[name=filter_group]").val();
        update_data["min_level"] = $(".advanced-filter-select[name=filter_level]").val();
        update_data["max_level"] = $(".advanced-filter-select[name=filter_level]").val();
        update_data["min_register"] = register_dates[$(".dates-select-bar .select-bar-container").slider("option", "values")[0]];
        update_data["max_register"] = register_dates[$(".dates-select-bar .select-bar-container").slider("option", "values")[1]];
    }
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.getList",
        type: "POST",
        data: update_data,
        success: function (raw_data) {
            data = jQuery.parseJSON(raw_data);
            console.log(data);
            nb_filtered_users = data.result.total_count;
            update_pagination_menu();
            current_users = data.result.users;
            generate_user_list();
            $(".user-col .icon-pencil").click(function () {
                let uid_index = $(this).closest('.user-container').attr('key');
                last_user_id = current_users[uid_index].id;
                last_user_index = uid_index;
                fill_user_edit(current_users[uid_index]);
                $("#UserList").fadeIn();
            });
            set_selected_to_selection();
        }
    });
}

function add_user() {
    let ajax_data = {
        pwg_token: pwg_token,
    }
    ajax_data.username = $('.AddUserLabelUsername .AddUserInput').val();
    ajax_data.password = $('.AddUserLabelPassword .AddUserInput').val();
    ajax_data.email = $(".AddUserLabelEmail .AddUserInput").val();
    ajax_data.send_password_by_mail = $('.user-list-checkbox[name="send_by_email"]').attr("data-selected") == "1" ? true : false;
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.add",
        type:"POST",
        data: ajax_data,
        beforeSend: function() {
            $("#AddUser .AddUserErrors").css("visibility", "hidden");
            if ($(".AddUserLabelUsername .AddUserInput").val() == "") {
                $("#AddUser .AddUserErrors p").html('&#x2718; '+missingUsername);
                $("#AddUser .AddUserErrors").css("visibility", "visible");
                return false;
            }
        },
        success: (raw_data) => {
            let data = jQuery.parseJSON(raw_data);
            if (data.stat == 'ok') {
                let new_user_id = data.result.users[0].id;
                update_user_list();
                add_user_close();
                $("#AddUser .AddUserInput").val("");
                $("#AddUserSuccess .edit-now").unbind("click").click(() => {
                    last_user_id = new_user_id;
                    last_user_index = get_container_index_from_uid(new_user_id);
                    if (last_user_index != -1) {
                        fill_user_edit(current_users[last_user_index]);
                        open_user_list();
                    } else {
                        get_user_info(new_user_id, open_user_list);
                    }
                })
                $("#AddUserSuccess label span:first").html("User %s added".replace("%s", ajax_data.username));
                $("#AddUserSuccess").show()
            }
            else {
                $("#AddUser .AddUserErrors p").html('&#x2718; '+data.message)
                $("#AddUser .AddUserErrors").css("visibility", "visible");
            }
        }
    });
}

function delete_user(uid) {
    jQuery.ajax({
        url: "ws.php?format=json&method=pwg.users.delete",
        type:"POST",
        data: {
            user_id:uid,
            pwg_token:pwg_token
        },
        beforeSend: function() {
            //jQuery('#user'+uid+' .userDelete .loading').show();
        },
        success:function(data) {
            close_user_list();
            update_user_list();
            // msg where user was deleted
            //jQuery('#showAddUser .infos').html('&#x2714; User '+username+' deleted').show();
        },
        error:function(XMLHttpRequest, textStatus, errorThrows) {
            //error just hide loading
            //jQuery('#user'+uid+' .userDelete .loading').hide();
        }
    })
}
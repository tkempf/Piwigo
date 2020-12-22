

{combine_script id='common' load='header' require='jquery' path='admin/themes/default/js/common.js'}

{combine_script id='jquery.selectize' load='header' path='themes/default/js/plugins/selectize.min.js'}
{combine_css id='jquery.selectize' path="themes/default/js/plugins/selectize.{$themeconf.colorscheme}.css"}

{combine_script id='jquery.ui.slider' require='jquery.ui' load='header' path='themes/default/js/ui/minified/jquery.ui.slider.min.js'}
{combine_css path="themes/default/js/ui/theme/jquery.ui.slider.css"}

{combine_script id='jquery.confirm' load='header' require='jquery' path='themes/default/js/plugins/jquery-confirm.min.js'}
{combine_css path="themes/default/js/plugins/jquery-confirm.min.css"}

{footer_script}

/* Translates */
const title_msg = '{'Are you sure you want to delete the user "%s"?'|@translate|escape:'javascript'}';
const are_you_sure_msg  = '{'Are you sure?'|@translate|@escape:'javascript'}';
const confirm_msg = '{'Yes, I am sure'|@translate|@escape}';
const cancel_msg = '{'No, I have changed my mind'|@translate|@escape}';
const str_and_others_tags = '{'and %s others'|@translate}';
const missingConfirm = "{'You need to confirm deletion'|translate|escape:javascript}";
const missingUsername = "{'Please, enter a login'|translate|escape:javascript}";

/* Template variables */
connected_user = {$connected_user};
groups_arr = [{$groups_arr}];
guest_id = {$guest_id};
nb_days = "{'%d days'|@translate}";
nb_photos_per_page = "{'%d photos per page'|@translate}";
pwg_token = '{$PWG_TOKEN}';

let register_dates_str = '{$register_dates}';
let register_dates = register_dates_str.split(',');
{literal}
let groupOptions = groups_arr.map(x => ({value: x[0], label: x[1], isSelected: 0}));
{/literal}

/* Startup */
setupRegisterDates(register_dates);
selectionMode(false);
get_guest_info();
update_user_list();
update_selection_content();

{/footer_script}

{combine_script id='user_list' load='footer' path='admin/themes/default/js/user_list.js'}

<div class="selection-mode-group-manager" style="right:30px">
  <label class="switch">
    <input type="checkbox" id="toggleSelectionMode">
    <span class="slider round"></span>
  </label>
  <p>{'Selection mode'|@translate}</p>
</div>


<div id="user-table">
  <div id="user-table-content">
    <div class="user-manager-header">
      <div style="display:flex;justify-content:space-between; flex-grow:1;">
        <div style="display:flex">
          <div class="not-in-selection-mode user-header-button add-user-button" style="margin-right:20px">
            <label class="user-header-button-label icon-plus-circled">
              <p>Add a User</p>
            </label>
          </div>

          <div class="not-in-selection-mode user-header-button" style="margin-right:20px">
            <label class="user-header-button-label icon-user-1 edit-guest-user-button">
              <p>Edit guest user</p>
            </label>
          </div>
          <div id="AddUserSuccess">
            <label class="icon-ok">
              <span>New user added</span><span class="icon-pencil edit-now">Edit it now</span>
            </label>
          </div>
          <div class="in-selection-mode">
            <p id="checkActions">
              <span>{'Select'|@translate}</span>
              <a href="#" id="selectAllPage">{'The whole page'|@translate}</a>
              <a href="#" id="selectSet">{'The whole set'|@translate}</a><span class="loading" style="display:none"><img src="themes/default/images/ajax-loader-small.gif"></span>
              <a href="#" id="selectNone">{'None'|@translate}</a>
              <a href="#" id="selectInvert">{'Invert'|@translate}</a>
              <span id="selectedMessage"></span>
            </p>
          </div>
        </div>
        <div style="display:flex">
          <div id="advanced_filter_button">
            <span>Advanced filter</span>
          </div>
          <div id='search-user'>
            <div class='search-info'> </div>
            <span class='icon-filter search-icon'> </span>
            <span class="icon-cancel search-cancel"></span>
            <input id="user_search" class='search-input' type='text' placeholder='{'Filter'|@translate}'>
          </div>
        </div>
      </div>
      <div class="not-in-selection-mode" style="width: 264px; height:2px">
      </div>
    </div>
    <div id="advanced-filter-container">
      <div class="advanced-filters-header">
        <span class="advanced-filter-title">Advanced filter</span>
        <span class="icon-cancel"></span>
      </div>
      <div class="advanced-filters">
        <div class="advanced-filter-status">
          <label class="advanced-filter-label">Status</label>
          <select class="user-action-select advanced-filter-select" name="filter_status">
            <option value="" label="" selected></option>
            {html_options options=$pref_status_options}
          </select>
        </div>
        <div class="advanced-filter-group">
          <label class="advanced-filter-label">Group</label>
          <select class="user-action-select advanced-filter-select" name="filter_group">
            <option value="" label="" selected></option>
            {html_options options=$association_options}
          </select>
        </div>
        <div class="advanced-filter-level">
          <label class="advanced-filter-label">Privacy level</label>
          <select class="user-action-select advanced-filter-select" name="filter_level" size="1">
            <option value="" label="" selected></option>
            {html_options options=$level_options}
          </select>
        </div>
        <div class="advanced-filter-date">

          <label class="advanced-filter-label">Date</label>
          <div class=" dates-select-bar">
              <p class="dates_info_min"></p>

              <p class="dates_info_max"></p>
              <div class="select-bar-wrapper">
                <div class="select-bar-container"></div>
              </div>
            </div>
        </div>
      </div>
    </div>
    <div class="user-container-header">
      <!-- edit / select -->
      <div class="user-header-col user-header-select no-flex-grow">
      </div>
      <!-- icon -->
      <div class="user-header-col user-header-initials no-flex-grow">
      </div>
      <!-- username -->
      <div class="user-header-col user-header-username">
        <span>Username</span>
      </div>
      <!-- status -->
      <div class="user-header-col user-header-status">
        <span>Status</span>
      </div>
      <!-- email adress -->
      <div class="user-header-col user-header-email not-in-selection-mode">
        <span>Email Adress</span>
      </div>
      <!-- groups -->
      <div class="user-header-col user-header-groups">
        <span>Groups</span>
      </div>
      <!-- registration date -->
      <div class="user-header-col user-header-registration">
        <span>Registration date</span>
      </div>
    </div>
    <div class="user-container-wrapper">
    </div>
    <!-- Pagination -->
    <div class="user-pagination">
      <div class="pagination-per-page">
        <span class="thumbnailsActionsShow" style="font-weight: bold;">{'Display'|@translate}</span>
        <a>5</a>
        <a>10</a>
        <a>25</a>
        <a>50</a>
      </div>

      <div class="pagination-container">
        <div class="pagination-arrow left">
          <span class="icon-left-open"></span>
        </div>
        <div class="pagination-item-container">
        </div>
        <div class="pagination-arrow rigth">
          <span class="icon-left-open"></span>
        </div>
      </div>
    </div>
  </div>
  <div id="selection-mode-block" class="in-selection-mode tag-selection" style="width: 250px; display: block;position:relative">
    <div class="user-selection-content">
      <div class="selection-mode-ul">
        <p>{'Your selection'|@translate}</p>
        <div class="user-selected-list">
        </div>
        <div class="selection-other-users"></div>
      </div>
      <fieldset id="action">
        <legend>{'Action'|@translate}</legend>

        <div id="forbidAction">{'No users selected, no actions possible.'|@translate}</div>
        <div id="permitActionUserList" style="display:block">

          <select class="user-action-select" name="selectAction">
            <option value="-1">{'Choose an action'|@translate}</option>
            <optgroup label="Actions">
              <option value="delete" class="icon-trash">{'Delete selected users'|@translate}</option>
              <option value="status">{'Status'|@translate}</option>
              <option value="group_associate">{'associate to group'|translate}</option>
              <option value="group_dissociate">{'dissociate from group'|@translate}</option>
              <option value="enabled_high">{'High definition enabled'|@translate}</option>
              <option value="level">{'Privacy level'|@translate}</option>
              <option value="nb_image_page">{'Number of photos per page'|@translate}</option>
              <option value="theme">{'Theme'|@translate}</option>
              <option value="language">{'Language'|@translate}</option>
              <option value="recent_period">{'Recent period'|@translate}</option>
              <option value="expand">{'Expand all albums'|@translate}</option>
      {if $ACTIVATE_COMMENTS}
              <option value="show_nb_comments">{'Show number of comments'|@translate}</option>
      {/if}
              <option value="show_nb_hits">{'Show number of hits'|@translate}</option>
            </optgroup>
          </select>
          {* delete *}
          <div id="action_delete" class="bulkAction">
            <div class="user-list-checkbox" name="confirm_deletion">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'Are you sure?'|@translate}</span>
            </div>
          </div>

          {* status *}
          <div id="action_status" class="bulkAction">
            <select class="user-action-select" name="status">
              {html_options options=$pref_status_options selected=$pref_status_selected}
            </select>
          </div>

          {* group_associate *}
          <div id="action_group_associate" class="bulkAction">

            <select class="user-action-select" name="associate">
              {html_options options=$association_options selected=$associate_selected}
            </select>
          </div>

          {* group_dissociate *}
          <div id="action_group_dissociate" class="bulkAction">
            <select class="user-action-select" name="dissociate">
              {html_options options=$association_options selected=$dissociate_selected}
            </select>
          </div>

          {* enabled_high *}
          <div id="action_enabled_high" class="bulkAction yes_no_radio" style="display:flex;justify-content:space-around">
            <span class="user-list-checkbox" name="enabled_high_yes">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'Yes'|@translate}</span>
            </span>
            <span class="user-list-checkbox" data-selected="1" name="enabled_high_no">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'No'|@translate}</span>
            </span>
          </div>

          {* level *}
          <div id="action_level" class="bulkAction">
            <select class="user-action-select" name="level" size="1">
              {html_options options=$level_options selected=$level_selected}
            </select>
          </div>

          {* nb_image_page *}
          <div id="action_nb_image_page" class="bulkAction">
            <div class="user-property-label photos-select-bar">{'Photos per page'|translate}
              <span> : </span><span class="nb-img-page-infos"></span>
              <div class="select-bar-wrapper">
                <div class="select-bar-container"></div>
              </div>
              <input name="nb_image_page" />
            </div>
          </div>

          {* theme *}
          <div id="action_theme" class="bulkAction">
            <select class="user-action-select" name="theme" size="1">
              {html_options options=$theme_options selected=$theme_selected}
            </select>
          </div>

          {* language *}
          <div id="action_language" class="bulkAction">
            <select class="user-action-select" name="language" size="1">
              {html_options options=$language_options selected=$language_selected}
            </select>
          </div>

          {* recent_period *}
          <div id="action_recent_period" class="bulkAction">
            <div class="user-property-label period-select-bar">{'Recent period'|translate}
              <span class="recent_period_infos"></span>
              <div class="select-bar-wrapper">
                <div class="select-bar-container"></div>
              </div>
            </div>
          </div>

          {* expand *}
          <div id="action_expand" class="bulkAction yes_no_radio">
            <span class="user-list-checkbox" name="expand_yes">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'Yes'|@translate}</span>
            </span>
            <span class="user-list-checkbox" data-selected="1" name="expand_no">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'No'|@translate}</span>
            </span>
          </div>

          {* show_nb_comments *}
          <div id="action_show_nb_comments" class="bulkAction yes_no_radio">
            <span class="user-list-checkbox" name="show_nb_comments_yes">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'Yes'|@translate}</span>
            </span>
            <span class="user-list-checkbox" data-selected="1" name="show_nb_comments_no">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'No'|@translate}</span>
            </span>
          </div>

          {* show_nb_hits *}
          <div id="action_show_nb_hits" class="bulkAction yes_no_radio">
            <span class="user-list-checkbox" name="show_nb_hits_yes">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'Yes'|@translate}</span>
            </span>
            <span class="user-list-checkbox" data-selected="1" name="show_nb_hits_no">
              <span class="select-checkbox">
                <i class="icon-ok"></i>
              </span>
              <span class="user-list-checkbox-label">{'No'|@translate}</span>
            </span>
          </div>

          <p id="applyActionBlock" style="display:none" class="actionButtons">
            <input id="applyAction" class="submit" type="submit" value="{'Apply action'|@translate}" name="submit"> <span id="applyOnDetails"></span></input>
            <span id="applyActionLoading" style="display:none"><img src="themes/default/images/ajax-loader-small.gif"></span>
            <br />
            <span class="infos" style="display:none">&#x2714; {'Users modified'|translate}</span>
          </p>
        </div> {* #permitActionUserList *}
      </fieldset>
    </div>
  </div>
</div>

<!-- User container template -->
<div id="template">
  <div class="user-container">
    <div class="user-col user-container-select in-selection-mode user-first-col no-flex-grow">
      <div class="user-container-checkbox user-list-checkbox" name="select_container">
        <span class="select-checkbox">
          <i class="icon-ok"></i>
        </span>
      </div>
    </div>
    <div class="user-col user-container-edit not-in-selection-mode user-first-col no-flex-grow">
      <span class="icon-pencil"></span>
    </div>
    <div class="user-col user-container-initials no-flex-grow">
      <div class="user-container-initials-wrapper">
        <span><!-- initials --></span>
      </div>
    </div>
    <div class="user-col user-container-username">
      <span><!-- name --></span>
    </div>
    <div class="user-col user-container-status">
      <span><!-- status --></span>
    </div>
    <div class="user-col user-container-email not-in-selection-mode">
      <span><!-- email --></span>
    </div>
    <div class="user-col user-container-groups">
      <!-- groups -->
    </div>
    <div class="user-col user-container-registration">
      <div>
        <span class="icon-clock registration-clock"></span>
        <div class="user-container-registration-info-wrapper">
          <span class="user-container-registration-date"><b><!-- date DD/MM/YY --></b></span>
          <span class="user-container-registration-time"><!-- time HH:mm:ss --></span>
        </div>
      </div>
    </div>
  </div>
  <span class="user-groups group-primary"></span>
  <span class="user-groups group-bonus"></span>
  <div class="user-selected-item">
    <a class="icon-cancel"></a>
    <p></p>
  </div>
</div>

<div id="UserList" class="UserListPopIn">

  <div class="UserListPopInContainer">

    <a class="icon-cancel CloseUserList"></a>
    <div class="summary-properties-update-container">
      <div class="summary-properties-container">
        <div class="summary-container">
          <div class="user-property-initials">
            <div>
              <span class="icon-blue">JP</span>
            </div>
          </div>
          <div class="user-property-username">
            <span class="edit-username-title">Jessy Pinkman</span>
            <span class="edit-username-specifier">(you)</span>
            <span class="edit-username icon-pencil"></span>
          </div>
          <div class="user-property-username-change">
            <div class="summary-input-container">
              <input class="user-property-input user-property-input-username" value="" placeholder="Username" />
            </div>
            <span class="icon-ok edit-username-validate"></span>
            <span class="icon-cancel-circled edit-username-cancel"></span>
          </div>
          <div class="user-property-password-container">
            <div class="user-property-password edit-password">
              <p class="icon-key user-property-button">Change Password</p>
            </div>
            <div class="user-property-password-change">
              <div class="summary-input-container">
              <input class="user-property-input user-property-input-password" value="" placeholder="Password" />
              </div>
              <span class="icon-ok edit-password-validate"></span>
              <span class="icon-cancel-circled edit-password-cancel"></span>
            </div>
            <div class="user-property-permissions">
              <p class="icon-lock user-property-button"><a href="#" >Permissions</a></p>
            </div>
          </div>
          <div class="user-property-register-visit">
            <p class="user-property-registered icon-clock"><!-- Registered string, example: 10 july 2018, 3 months ago --></p>
            <p class="user-property-last-visit icon-clock"><!-- Last Visit string, example: 12 october 2018, 4 hours ago --></p>
          </div>
        </div>
        <div class="properties-container">
          <div class="user-property-column-title">
            <p>Properties</p>
          </div>
          <div class="user-property-email">
            <p class="user-property-label">Email Adress</p>
            <input type="text" class="user-property-input" value="contact@jessy-pinkman.com" />
          </div>
          <div class="user-property-status">
            <p class="user-property-label">Status</p>
            <div class="user-property-select-container">
              <select name="status" class="user-property-select">
                <option value="webmaster">Webmaster</option>
                <option value="admin">Admin</option>
                <option value="normal">normal</option>
                <option value="generic">generic</option>
                <option value="guest">guest</option>
              </select>
            </div>
          </div>
          <div class="user-property-level">
            <p class="user-property-label">Privacy Level</p>
            <div class="user-property-select-container">
              <select name="privacy" class="user-property-select">
                <option value="0">---</option>
                <option value="1">Contacts</option>
                <option value="2">Amis</option>
                <option value="4">Famille</option>
                <option value="8">Admin</option>
              </select>
            </div>
          </div>
          <div class="user-property-group-container">
            <p class="user-property-label">Groups</p>
            <div class="user-property-select-container user-property-group">
              <select class="user-property-select" data-selectize="groups" placeholder="{'Select groups or type them'|translate}" 
                name="group_id[]" multiple style="box-sizing:border-box;"></select>
            </div>
          </div>

          <div class="user-list-checkbox" name="hd_enabled">
            <span class="select-checkbox">
              <i class="icon-ok"></i>
            </span>
            <span class="user-list-checkbox-label">{'High definiton enabled'|translate}</span>
          </div>
        </div>
      </div>
      <div class="update-container" style="display:flex;justify-content:space-between;">
          <div>
            <span class="update-user-button">Update</span>
            <span class="close-update-button">Close</span>
            <span class="update-user-success icon-green"> User updated </span>
          </div>
          <div>
            <span class="delete-user-button icon-trash">Delete user</span>
          </div>
      </div>
    </div>
    <div class="preferences-container">
      <div class="user-property-column-title">
        <p>{'Preferences'|translate}</p>
      </div>
      <div class="user-property-label photos-select-bar">{'Photos per page'|translate}
        <span> : </span><span class="nb-img-page-infos"></span>
        <div class="select-bar-wrapper">
          <div class="select-bar-container"></div>
        </div>
        <input name="recent_period" />
      </div>
      <div class="user-property-theme">
        <p class="user-property-label">Theme</p>
        <div class="user-property-select-container">
          <select name="privacy" class="user-property-select">
            {html_options options=$theme_options selected=$theme_selected}
          </select>
        </div>
      </div>
      <div class="user-property-lang">
        <p class="user-property-label">Language</p>
        <div class="user-property-select-container">
          <select name="privacy" class="user-property-select">
            {html_options options=$language_options selected=$language_selected}
          </select>
        </div>
      </div>
      <div class="user-property-label period-select-bar">{'Recent period'|translate}
        <span class="recent_period_infos">7 jours</span>
        <div class="select-bar-wrapper">
          <div class="select-bar-container"></div>
        </div>
      </div>
      
      <div class="user-list-checkbox" name="expand_all_albums">
        <span class="select-checkbox">
          <i class="icon-ok"></i>
        </span>
        <span class="user-list-checkbox-label">{'Expand all albums'|translate}</span>
      </div>
      <div class="user-list-checkbox" name="show_nb_comments">
        <span class="select-checkbox">
          <i class="icon-ok"></i>
        </span>
        <span class="user-list-checkbox-label">{'Show number of comments'|translate}</span>
      </div>
      <div class="user-list-checkbox" name="show_nb_hits">
        <span class="select-checkbox">
          <i class="icon-ok"></i>
        </span>
        <span class="user-list-checkbox-label">{'Show number of hits'|translate}</span>
      </div>
    </div> 
  </div>
</div>


<div id="GuestUserList" class="UserListPopIn">

  <div class="GuestUserListPopInContainer">

    <a class="icon-cancel CloseUserList CloseGuestUserList"></a>
    <div id="guest-msg" style="background-color:#B9E2F8;padding:5;border-left:3px solid blue;display:flex;align-items:center;margin-bottom:30px">
      <span class="icon-info-circled-1" style="background-color:#B9E2F8;color:#26409D;font-size:3em"></span><span style="font-size:1.1em;color:#26409D;font-weight:bold;">Users not logged in will have these settings applied, these settings are used by default for new users</span>
    </div>
    <div style='display:flex;'>
      <div class="summary-properties-update-container">
      <div class="summary-properties-container">
        <div class="summary-container">
          <div class="user-property-initials">
            <div>
              <span class="icon-blue">JP</span>
            </div>
          </div>
          <div class="user-property-username">
            <span class="edit-username-title">Jessy Pinkman</span>
            <span class="edit-username-specifier">(you)</span>
          </div>
          <div class="user-property-username-change">
            <div class="summary-input-container">
              <input class="user-property-input user-property-input-username" value="" placeholder="Username" />
            </div>
            <span class="icon-ok edit-username-validate"></span>
            <span class="icon-cancel-circled edit-username-cancel"></span>
          </div>
          <div class="user-property-password-container">
            <div class="user-property-password edit-password">
              <p class="icon-key user-property-button unavailable">Change Password</p>
            </div>
            <div class="user-property-password-change">
              <div class="summary-input-container">
              <input class="user-property-input user-property-input-password" value="" placeholder="Password" />
              </div>
              <span class="icon-ok edit-password-validate"></span>
              <span class="icon-cancel-circled edit-password-cancel"></span>
            </div>
            <div class="user-property-permissions">
              <p class="icon-lock user-property-button"><a href="admin.php?page=user_perm&user_id={$guest_id}" >Permissions</a></p>
            </div>
          </div>
        </div>
        <div class="properties-container">
          <div class="user-property-column-title">
            <p>Properties</p>
          </div>
          <div class="user-property-email">
            <p class="user-property-label">Email Adress</p>
            <input type="text" class="user-property-input" value="N/A" readonly />
          </div>
          <div class="user-property-status">
            <p class="user-property-label">Status</p>
            <div class="user-property-select-container">
              <select name="status" class="user-property-select">
                <option value="guest">Guest</option>
              </select>
            </div>
          </div>
          <div class="user-property-level">
            <p class="user-property-label">Privacy Level</p>
            <div class="user-property-select-container">
              <select name="privacy" class="user-property-select">
                <option value="0">---</option>
                <option value="1">Contacts</option>
                <option value="2">Amis</option>
                <option value="4">Famille</option>
                <option value="8">Admin</option>
              </select>
            </div>
          </div>
          <div class="user-property-group-container">
            <p class="user-property-label">Groups</p>
            <div class="user-property-select-container user-property-group">
              <select class="user-property-select" data-selectize="groups" placeholder="{'Select groups or type them'|translate}" 
                name="group_id[]" multiple style="box-sizing:border-box;"></select>
            </div>
          </div>

          <div class="user-list-checkbox" name="hd_enabled">
            <span class="select-checkbox">
              <i class="icon-ok"></i>
            </span>
            <span class="user-list-checkbox-label">{'High definiton enabled'|translate}</span>
          </div>
        </div>
      </div>
      <div class="update-container">
          <span class="update-user-button">Update</span>
          <span class="close-update-button">Close</span>
          <span class="update-user-success icon-green"> User updated </span>
      </div>
      </div>
      <div class="preferences-container">
        <div class="user-property-column-title">
          <p>{'Preferences'|translate}</p>
        </div>
        <div class="user-property-label photos-select-bar">{'Photos per page'|translate}
          <span> : </span><span class="nb-img-page-infos"></span>
          <div class="select-bar-wrapper">
            <div class="select-bar-container"></div>
          </div>
          <input name="recent_period" />
        </div>
        <div class="user-property-theme">
          <p class="user-property-label">Theme</p>
          <div class="user-property-select-container">
            <select name="privacy" class="user-property-select">
              {html_options options=$theme_options selected=$theme_selected}
            </select>
          </div>
        </div>
        <div class="user-property-lang">
          <p class="user-property-label">Language</p>
          <div class="user-property-select-container">
            <select name="privacy" class="user-property-select">
              {html_options options=$language_options selected=$language_selected}
            </select>
          </div>
        </div>
        <div class="user-property-label period-select-bar">{'Recent period'|translate}
          <span class="recent_period_infos"><!-- 7 days --></span>
          <div class="select-bar-wrapper">
            <div class="select-bar-container"></div>
          </div>
        </div>

        <div class="user-list-checkbox" name="expand_all_albums">
          <span class="select-checkbox">
            <i class="icon-ok"></i>
          </span>
          <span class="user-list-checkbox-label">{'Expand all albums'|translate}</span>
        </div>
        <div class="user-list-checkbox" name="show_nb_comments">
          <span class="select-checkbox">
            <i class="icon-ok"></i>
          </span>
          <span class="user-list-checkbox-label">{'Show number of comments'|translate}</span>
        </div>
        <div class="user-list-checkbox" name="show_nb_hits">
          <span class="select-checkbox">
            <i class="icon-ok"></i>
          </span>
          <span class="user-list-checkbox-label">{'Show number of hits'|translate}</span>
        </div>
      </div>
    </div>
  </div>
</div>

<div id="AddUser" class="UserListPopIn">
  <div class="AddUserPopInContainer">
    <a class="icon-cancel CloseUserList CloseAddUser"></a>
    
    <div class="AddIconContainer">
      <span class="AddIcon icon-blue icon-plus-circled"></span>
    </div>
    <div class="AddIconTitle">
      <span>Add a new user</span>
    </div>
    <div class="AddUserInputContainer">
      <label class="AddUserLabel AddUserLabelUsername"> Username
        <input class="AddUserInput" />
      </label>
    </div>

    <div class="AddUserInputContainer">
      <div class="AddUserPasswordWrapper">
        <label for="AddUserPassword" class="AddUserLabel AddUserLabelPassword"> Password</label>
        <span id="show_password" class="icon-eye">Show</span>
      </div>
      <input id="AddUserPassword" class="AddUserInput" type="password"/>

      <div class="AddUserGenPassword">
        <span class="icon-dice-solid"></span><span>Generate random password</span>
      </div>
    </div>

    <div class="AddUserInputContainer">
      <label class="AddUserLabel AddUserLabelEmail"> Email
        <input class="AddUserInput" />
      </label>
    </div>

    <div class="user-list-checkbox" name="send_by_email">
      <span class="select-checkbox">
        <i class="icon-ok"></i>
      </span>
      <span class="user-list-checkbox-label">{'Send connection settings by email'|translate}</span>
    </div>

    <div class="AddUserErrors icon-red">
      <p>X</p>
    </div>

    <div class="AddUserSubmit">
      <span class="icon-plus"></span><span>Add User</span>
    </div>

    <div class="AddUserCancel" style="display:none;">
      <span>Cancel</span>
    </div>
  </div>
</div>

<style>

/* general */
.no-flex-grow {
    flex-grow:0 !important;
}

#template {
    display:none;
}

/* selection mode */

.user-selection-content {
	margin-top: 90px;
	padding: 5px;
}

#user-table #selection-mode-block{
  display:none;
  position: relative;
  width: 223px;
  top: -20px;
  min-height:calc(100vh - 171px);
}

#forbidAction {
  padding:5px;
}
/* user header */

.user-manager-header {
	display: flex;
	flex-wrap: nowrap;
	align-items: center;
	overflow: hidden;
  padding-bottom:5px;
}

.user-header-button {
  position:relative;
}

.user-header-button-label {
	position: relative;
	padding: 10px;
	background-color: #fafafa;
	box-shadow: 0px 2px #00000024;
	border-radius: 5px;
	font-weight: bold;
	display: flex;
	align-items: baseline;
	cursor: pointer;
}


.user-header-button-label p {
  margin:0;
}

#AddUserSuccess {
  display:none;
  font-weight:bold;
}

#AddUserSuccess span {
  color: #0a0;
}

#AddUserSuccess label {
  padding: 10px;
  background-color:  #c2f5c2;
  border-left: 2px solid #00FF00;
  cursor: default;
  color: #0a0;
}

#AddUserSuccess .edit-now {
  color: #3a3a3a;
  cursor: pointer;
  margin-left:10px;
}

/* filters bar */

#search-user {
    
}

/* Pagination */
.user-pagination {
    margin: 0;
    display: flex;
    padding: 0;
    justify-content: space-between;
    align-items: center;
}

/* User Table */
#user-table {
    margin-left:30px;
    display:flex;
    flex-wrap:nowrap;
    min-height: calc(100vh - 216px);
}

#user-table-content {
    min-width:80%;
    max-width:100%;
    flex-grow:1;
    display:flex;
    flex-direction:column;
    margin-right:30px;
}

.user-container-header {
    display:flex;
    text-align:left;
    font-size:1.3em;
    font-weight:bold;
    margin-top:20px;
    color:#9e9e9e;
}

.user-header-col {
    height:50px;
    flex-grow:1;
}

/* User Container */
.user-container {
    display:flex;
    width:100%;
    height:80px;
    background-color:#F3F3F3;
    font-weight:bold;
    border-radius:10px;
    margin-bottom:20px;
    transition: background-color 500ms linear;
}

.user-header-select,
.user-container-select,
.user-container-edit {
    width:40px;
}

.user-header-initials,
.user-container-initials {
    width:80px;
}

.user-header-username,
.user-container-username {
    width:20%;
}

.user-header-status,
.user-container-status {
    width:10%;
}

.user-header-email,
.user-container-email {
    width:20%;
}

.user-header-groups,
.user-container-groups {
    width:25%;
}

.user-header-registration,
.user-container-registration {
    width: 15%;
}

.user-col {
    text-align: left;
    padding: 0;
    height:100%;
    display:flex;
    align-items:center;
    flex-grow:1;
}

.user-first-col {
    border-top-left-radius: 15%;
    border-bottom-left-radius: 15%;
}

.user-first-col:hover {
    background-color:#FFC276;
}

.user-container-checkbox.user-list-checkbox {
    margin-bottom:0px;
}


.user-container-checkbox.user-list-checkbox .select-checkbox {
  border: solid #E6E6E6 2px;
  background-color: #F3F3F3;
}


.user-container.container-selected .user-container-checkbox.user-list-checkbox .select-checkbox {
  background-color: #ffa646;
  border: solid #ffa646 2px;
}

.user-container-checkbox.user-list-checkbox i {
    margin-left:7px;
}

.user-container-select {
    display:flex;
    justify-content:center;
    align-items:center;
}

.user-container-select span {
    font-size:1.5em;
    border: 1px solid #E6E6E6;
    border-radius:50%;
    background-color:#F3F3F3;
    width:27px;
}

.user-container-select span > i {
    display:none;
}

.user-container-edit {
  justify-content: center;
}

.user-container-edit span {
    font-weight:bold;
    font-size:1.5em;
    cursor:pointer;
    width:27px;
}

.user-container-initials-wrapper {
    padding-left:10px;
}

.user-container-initials-wrapper > span {
    border-radius:50%;
    padding:5px;
    width:40px;
    height:40px;
    display:inline-block;
    text-align:center;
    font-size:1.5em;
    line-height:1.9em;
}

.user-container-status {
    text-transform:capitalize;
}

.user-container-registration {
    width:15%;
}

.user-container-registration > div {
    display:flex;
}

.registration-clock {
    background:#E3E5E5;
    padding:5px;
    width:50%;
    height:50%;
    border-radius:30px;
    margin-right:5px;
    font-size:1.5em;
}

.user-container-registration-info-wrapper {
    display:flex;
    flex-direction:column;
}

.user-groups {
    margin-left: 5px;
    border-radius:9999px;
    padding: 10px 15px;
}

.group-primary {
    max-width:20%;
    text-overflow: ellipsis;
    overflow:hidden;
    white-space:nowrap;
}

/* User container selected */

.user-container.container-selected {
    display:flex;
    width:100%;
    height:80px;
    background-color:#FFD9A7;
    font-weight:bold;
    border-radius:10px;
    margin-bottom:20px;
}


.user-container.container-selected .user-container-initials-wrapper > span {
  background-color: #FF7B00;
  color:#FEE7BD;
}

.user-container.container-selected .user-groups {
  background-color: #FEE7C8;
  color:#FF7B00;
}

/* User Edit Pop-in */
#UserList {
    font-size:1em;
}

.UserListPopIn{
    position: fixed;
    z-index: 100;
    left: 0;
    top: 0;
    width: 100%; 
    height: 100%;
    overflow: auto; 
    background-color: rgba(0,0,0,0.7);
}

.UserListPopInContainer{
    display:block;
    width:1100px;
    position:absolute;
    left:50%;
    top: 50%;
    transform:translate(-50%, -48%);
    text-align:left;
    padding:30px;
    display:flex;
    background-color:white;
    padding:30px;
    width:1020px
}

.summary-properties-update-container {
    height:100%;
    display:flex;
    flex-direction:column
}

.summary-properties-container {
    display:flex;
    flex-grow:1;
}

.summary-container {
    width:300px;
    display:flex;
    flex-direction:column;
    align-items:center;
    padding:5px;
    padding-right:30px;
}

.properties-container {
    width:300px;
    border-left:solid 1px #ddd;
    padding-left:30px;
    padding-right:30px;
    padding-bottom:20px;
}

.update-container {
    border-top:solid 1px #ddd;
    padding-right:30px;
    padding-top:30px;
}

.preferences-container {
    width:300px;
    padding-left:30px;
    border-left: solid 1px #ddd;
}

/* general pop in rules */
.user-property-column-title {
    color:#353535;
    font-weight:bold;
    margin-bottom:30px;
    font-size:1.7em;
}

.user-property-column-title > p {
    margin:0;
}


.user-property-label {
    color:#A4A4A4;
    font-weight:bold;
    font-size:1.3em;
    margin-bottom:10px;
}

.user-property-input {
    width: 100%;
    box-sizing:border-box;
    font-size:1.1em;
    padding:10px 20px;
    border:none;
    color:#353535;
    background-color:#F3F3F3;
}

.user-property-input[type="text"] {
    background-color:#F3F3F3;
}


.user-property-button {
    margin-top:0;
    font-size:1.3em;
    color:#353535;
    margin-bottom:20px;
    cursor:pointer;
    padding:10px 20px;
    border:none;
    color:#353535;
    background-color:#F3F3F3;
}

.user-property-select {
    box-sizing: border-box;
    background-color:#F3F3F3;
    color:#353535;
    -webkit-appearance:none;
    border:none;
    width:100%;
    padding: 10px 20px;
    font-size:1.1em;
}

.user-property-select-container {
    margin-bottom: 20px;
}

.user-property-select-container::before {
    content: '\e835';
    font-size:1em;
    font-family:"fontello";
    color: #353535;
    pointer-events:none;
    position:absolute;
    margin-left:270px;
    margin-top:10px;
}

.select-bar-wrapper {
    padding-left:10px;
    margin-top: 20px;
    margin-bottom: 30px;
}

.select-bar-wrapper .ui-slider-horizontal .ui-slider-handle{
    background-color:#FFA646;
    border:none;
    border-radius:25px;
    border: 1px solid #818181;
}

.select-bar-wrapper .ui-slider-horizontal .ui-slider-range-min{
    background-color:#818181;
    border-radius:25px;
}

.select-bar-wrapper .ui-slider-horizontal{
    background-color:#e3e3e3;
    border:none;
    border-radius:25px;
}

.user-list-checkbox {
    margin-bottom:15px;
}

.user-list-checkbox i {
    margin-left:7px;
}

.user-list-checkbox-label {
    margin-left: 10px;
    vertical-align:top;
    font-size:1.2em;
    cursor:pointer;
}

/* summary section */
.user-property-initials {
    margin-bottom: 40px;
}

.user-property-initials > div {
    padding-left:10px;
}

.user-property-initials span{
    border-radius:50%;
    padding:5px;
    width:120px;
    height:120px;
    display:inline-block;
    text-align:center;
    font-size:4.5em;
    line-height:2em;
    font-weight:bold;
}

.user-property-username {
    font-weight:bold;
    margin-bottom:40px;
    height:38px;
}

.user-property-username-change {
    justify-content:center;
    align-items:center;
    display:none;
    margin-bottom:40px;
}

.user-property-password-change {
  display:none;
}

.summary-input-container {
  width:230px;
  display:inline-block;
}

.edit-username {
    font-size:1.5em;
    cursor:pointer;
}

.edit-username-title {
    font-size:1.5em;
    color:#353535;
}

.edit-username-specifier {
    font-size:1.5em;
    color:#A4A4A4;
}

.user-property-input.user-property-input-username {
    border: solid 2px #ffa744;
    background: none;
    padding: 9px;
}

.user-property-input.user-property-input-username:hover {
    background-color: #f0f0f0 !important;
}

.user-property-password-container {
    display:flex;
    flex-direction:column;
    margin-bottom:40px;
    width:100%;
}

.edit-username-validate,
.edit-password-validate {
    display: block;
    margin: auto 5px;
    cursor: pointer;
    background-color: #ffa744;
    color: #3c3c3c;
    font-size: 17px;
    font-weight: 700;
    padding: 7px 5.5px;
}

.edit-username-validate:hover,
.edit-password-validate:hover {
    background-color: #f70;
    color: #000;
    cursor: pointer;
}

.edit-username-cancel,
.edit-password-cancel {
    cursor:pointer;
    font-size:22px;
    padding-top: 4px;
}

.edit-username-cancel:hover,
.edit-password-cancel:hover {
    color: #ff7700;
}

.user-property-input.user-property-input-password {
    border: solid 2px #ffa744;
    background: none;
    padding: 9px;
}

.user-property-input.user-property-input-password:hover {
    background-color: #f0f0f0 !important;
}

.user-property-registered-visit {
    color:#A4A4A4;
    font-weight:bold;
    font-size:1.2em;
}

.user-property-registered-visit p {
    margin:0;
}

/* properties */

.user-property-group-container {
  margin-bottom:20px;
}


.user-property-select > .selectize-input.items {
    padding:0;
}

.user-property-group .selectize-input.items {
    border:none;
    background-color: #F3F3F3;
}


/* preferences */

.nb-img-page-infos {
    color:#353535;
    font-weight:normal;
}

.photos-select-bar input {
    display:none;
}

.recent_period_infos {
    margin-left:15px;
    color:#353535;
    font-weight:normal;
}

/* update */

.update-user-button {
    cursor:pointer;
    color:#353535;
    padding:10px 20px;
    background-color: #F3F3F3;
    font-size:1.1em;
    font-weight:bold;

    background-color: #FFC275;
    color: white;
}

.update-user-button.can-update {
    background-color: #FFC275;
    color: white;
}

.close-update-button {
    cursor: pointer;
    color: #A4A4A4;
    padding:10px 20px;
    font-size:1.1em;
    font-weight:bold;
}

.delete-user-button {
    cursor:pointer;
    color:#353535;
    padding:10px 20px;
    background-color: #F3F3F3;
    font-size:1.1em;
    font-weight:bold;
}

.update-user-success {
    padding:10px;
    display:none
}
/* Guest Pop in */

#GuestUserList {
  display:none;
}

.GuestUserListPopIn {
    position: fixed;
    z-index: 100;
    left: 0;
    top: 0;
    width: 100%; 
    height: 100%;
    overflow: auto; 
    background-color: rgba(0,0,0,0.7);
}


.GuestUserListPopInContainer{
    display:flex;
    position:absolute;
    left:50%;
    top: 50%;
    transform:translate(-50%, -48%);
    text-align:left;
    padding:30px;
    display:flex;
    background-color:white;
    padding:30px;
    width:1020px;
    flex-direction:column;
    border-radius:15px;
}

.unavailable {
  color:#CBCBCB;
}

/* Add User Pop In */

#AddUser {
  display:none;
}

.AddUserPopInContainer{
    display:flex;
    position:absolute;
    left:50%;
    top: 50%;
    transform:translate(-50%, -48%);
    text-align:left;
    background-color:white;
    padding:40px;
    flex-direction:column;
    border-radius:15px;
    align-items:center;
    width: min-content;
}

.AddIconContainer {
}

.AddIcon {
  border-radius:9999px;
  padding:10px;
  font-size: 2em;
}

.AddIconTitle {
  font-size:1.7em;
  font-weight:bold;
  color: #000000;
  margin-bottom:25px;
  margin-top:15px;
}

.AddUserInputContainer {
  display: flex;
  flex-direction: column;
  margin: 25px 0px;
  width:100%;
}

.AddUserLabel {
  display:block;
  color: #3E3E3E;
  font-size:1.4em;
}

.AddUserInput {
  display:block;
  background-color:white;
  border: solid 1px #D4D4D4;
  font-size:1.4em;
  padding: 10px 5px;
}

.AddUserInput[type="password"],
.AddUserInput[type="text"] {
  background-color:white;
}

.AddUserPasswordWrapper {
  display:flex;
  justify-content:space-between;
}

.AddUserPasswordWrapper span {
  font-size:1.4em;
  cursor:pointer;
}


.AddUserPasswordWrapper:hover {
  color:#ffa646;
}

.AddUserGenPassword {
  margin-top: 5px;
  font-size: 1.2em;
  cursor:pointer;
}
.AddUserGenPassword:hover, .AddUserGenPassword:active {
  color:#ffa646;
}

.AddUserGenPassword span {
  margin-right:10px;
}

.AddUserErrors {
  visibility:hidden;
  width:100%;
  padding:5px;
  border-left:solid 3px red;
}

.AddUserErrors p {
	font-size: 14px;
	font-weight: bold;
	padding-left: 10px;
	height: 40px;
}

.AddUserSubmit {
  cursor:pointer;
  font-weight:bold;
  color: #3F3E40;
  background-color: #FFA836;
  padding: 10px;
  margin: 15px;
  font-size:1.1em;
  margin-bottom:0;
}

.AddUserCancel {
  color: #3F3E40;
  font-weight: bold;
  cursor: pointer;
  font-size:1.1em;
}

/* Selectize Inputs (groups) */

#UserList .item,
#UserList .item.active,
#GuestUserList .item,
#GuestUserList .item.active {
  background-image:none;
  background-color: #ffa744;
  border-color: black;
}


#UserList .item .remove,
#GuestUserList .item .remove {
  border-color: black;
}

/* selection panel */
#permitActionUserList .user-list-checkbox i {
	margin-left: 0px;
}

.user-selected-item {
	display: flex;
	margin: 10px;
	text-align: start;
}

.user-selected-item p {
	width: 85%;
	text-overflow: ellipsis;
	overflow: hidden;
	white-space: nowrap;
	color: #a0a0a0;
	margin: 0;
}

.selection-other-users {
  display:block;
	color: #ffa646;
	font-weight: bold;
	font-size: 15px;
}

.user-action-select {
	background: white;
	-webkit-appearance: none;
	padding: 5px 10px;
  width:100%;
}

.user-action-select[name="selectAction"] {
  margin-bottom:30px;
}

.search-icon {
  top: 212px;
  z-index: 13;
}

/*----------------------
Advanced filter
----------------------*/
#advanced_filter_button {
  cursor:pointer;
  margin:4px;
  padding:10px;
  background-color:#F3F3F3;
}

#advanced-filter-container {
  display:none;
  background-color:#F3F3F3;
  padding:10px;
}

.advanced-filters-header {
  display:flex;
  justify-content:space-between;
  margin-bottom:10px;
}

.advanced-filter-title {
  font-weight:bold;
  color:#3e3e3e;
  font-size:1.2em;
}

.advanced-filters {
  display:flex;
  padding:5px;
}

.advanced-filter-status, 
.advanced-filter-group, 
.advanced-filter-level, 
.advanced-filter-date {
  width:25%;
}

.advanced-filter-label {
  text-align:left;
  font-size:1.3em;
  display:block;
  color: #3D3D3D;
  margin-bottom:5px;
}

.advanced-filter-select {
  width:85%;
  display:block;
}

</style>

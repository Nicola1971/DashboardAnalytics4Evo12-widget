/**
 * DashboardAnalytics4Evo12 
 *
 * Dashboard Analytics widget for MODX Evolution CMS 1.2
 *
 * @author      Nicola Lambathakis http://www.tattoocms.it/
 * @category    plugin
 * @version     1 RC1.2
 * @license	    http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnManagerWelcomeHome,OnManagerWelcomePrerender
 * @internal    @installset base
 * @internal    @modx_category Analytics
 * @internal    @disabled 1
 * @internal    @properties &wdgVisibility=Show widget for:;menu;All,AdminOnly,AdminExcluded,ThisRoleOnly,ThisUserOnly;All &ThisRole=Run only for this role:;string;;;(role id) &ThisUser=Run only for this user:;string;;;(username) &wdgTitle= Analytics widget Title:;string;Analytics  &wdgicon= widget icon:;string;fa-bar-chart &datarow= widget row position:;menu;1,2,3,4,5,6,7,8,9,10;1 &datacol= widget col position:;menu;1,2,3,4;1 &datasizex= widget x size:;menu;1,2,3,4;4 &datasizey= widget y size:;menu;1,2,3,4,5,6,7,8,9,10;6 &IDclient=ID client:;string;;;application ID client &ids=ids:;;;Table ID (ids) &sess_metrics=metrics:;menu;sessions,users;sessions &sess_time=time period:;menu;7daysAgo,14daysAgo,30daysAgo,60daysAgo;30daysAgo &rightNow=Realtime Users Title:;string;Right Now
 * @documentation Requirements: This plugin requires MODx Evolution 1.2 to 1.2.2
 * @reportissues https://github.com/Nicola1971/DashboardAnalytics4Evo12-widget/issues
 * @link        
 * @lastupdate  10/01/2017
*/
// get manager role
$internalKey = $modx->getLoginUserID();
$sid = $modx->sid;
$role = $_SESSION['mgrRole'];
$user = $_SESSION['mgrShortname'];
// show widget only to Admin role 1
if(($role!=1) AND ($wdgVisibility == 'AdminOnly')) {}
// show widget to all manager users excluded Admin role 1
else if(($role==1) AND ($wdgVisibility == 'AdminExcluded')) {}
// show widget only to "this" role id
else if(($role!=$ThisRole) AND ($wdgVisibility == 'ThisRoleOnly')) {}
// show widget only to "this" username
else if(($user!=$ThisUser) AND ($wdgVisibility == 'ThisUserOnly')) {}
else {
// get language
global $modx,$_lang;
// get plugin id
$result = $modx->db->select('id', $this->getFullTableName("site_plugins"), "name='{$modx->event->activePlugin}' AND disabled=0");
$pluginid = $modx->db->getValue($result);
if($modx->hasPermission('edit_plugin')) {
$button_pl_config = '<a data-toggle="tooltip" href="javascript:;" title="' . $_lang["settings_config"] . '" class="text-muted pull-right" onclick="parent.modx.popup({url:\''. MODX_MANAGER_URL.'?a=102&id='.$pluginid.'&tab=1\',title1:\'' . $_lang["settings_config"] . '\',icon:\'fa-cog\',iframe:\'iframe\',selector2:\'#tabConfig\',position:\'center center\',width:\'80%\',height:\'80%\',hide:0,hover:0,overlay:1,overlayclose:1})" ><i class="fa fa-cog"></i> </a>';
}
$modx->setPlaceholder('button_pl_config', $button_pl_config);
$WidgetOutput = ''.$modx->getChunk(''.$WidgetChunk.'').'';
$e = &$modx->Event;
switch($e->name){
case 'OnManagerWelcomePrerender':
$cssOutput = "
<script>
(function(w,d,s,g,js,fjs){
  g=w.gapi||(w.gapi={});g.analytics={q:[],ready:function(cb){this.q.push(cb)}};
  js=d.createElement(s);fjs=d.getElementsByTagName(s)[0];
  js.src='https://apis.google.com/js/platform.js';
  fjs.parentNode.insertBefore(js,fjs);js.onload=function(){g.load('analytics')};
}(window,document,'script'));
</script>
<script src=\"../assets/plugins/analytics4evo12/moment.min.js\"></script>
<script src=\"../assets/plugins/analytics4evo12/active-users.js\"></script>
<script>
gapi.analytics.ready(function() {
  // Authorize the user.
  var CLIENT_ID =  '$IDclient';
  gapi.analytics.auth.authorize({
    container: 'auth-button',
    clientid: CLIENT_ID,
    userInfoLabel:\"\"
  });
   var activeUsers = new gapi.analytics.ext.ActiveUsers({
    container: 'active-users',
	filters: null,
	template: '<div class=\"ActiveUsers\">' + '$rightNow <br/><h1><b class=\"ActiveUsers-value\"></b></h1>' +  '</div>',
    pollingInterval: 5,
	'ids': \"$ids\"
  });
  // widgetSessions: Create the timeline chart.
  var widgetSessions = new gapi.analytics.googleCharts.DataChart({
    reportType: 'ga',
    query: {
      'dimensions': 'ga:date',
      'metrics': 'ga:$sess_metrics',
      'start-date': '$sess_time',
      'end-date': 'yesterday',
	  'max-results': 30,
     'ids': \"$ids\"
    },
    chart: {
      type: 'LINE',
      container: 'widgetSessions',
      options: {
	    height: '200px',
        width: '100%'
      }
    }
  }); 
  gapi.analytics.auth.on('success', function(response) {
    //hide the auth-button
    document.querySelector(\"#auth-button\").style.display='none';  
    widgetSessions.execute();
    activeUsers.execute();
  });
(function($,sr){
  // debouncing function from John Hann
  // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
  var debounce = function (func, threshold, execAsap) {
      var timeout;
      return function debounced () {
          var obj = this, args = arguments;
          function delayed () {
              if (!execAsap)
                  func.apply(obj, args);
              timeout = null;
          };

          if (timeout)
              clearTimeout(timeout);
          else if (execAsap)
              func.apply(obj, args);

          timeout = setTimeout(delayed, threshold || 100);
      };
  }
  // smartresize 
  jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

})(jQuery,'smartresize');
//resize charts
jQuery(document).ready(function () {
    jQuery(window).smartresize(function () {
        widgetSessions.execute();
    });
});
});
</script>
<style>
div#active-users {height:84px;color:#058DC7;display:block;margin-top:8px;text-align:center;vertical-align:middle;padding:0;}
div#active-users .ActiveUsers-value {color:#ff9900; display:block; margin-top:-30px;margin-bottom:-30px;padding:0; font-size: 3.6rem !important; font-weight:normal!important;}
</style>
<div id=\"auth-button\"></div>";
$e->output($cssOutput);
break;
case 'OnManagerWelcomeHome':
		//widget name
$WidgetID = isset($WidgetID) ? $WidgetID : 'gaBox';
// size and position
$datarow = isset($datarow) ? $datarow : '1';
$datacol = isset($datacol) ? $datacol : '2';
$datasizex = isset($datasizex) ? $datasizex : '2';
$datasizey = isset($datasizey) ? $datasizey : '2';
$WidgetOutput = "
<li id=\"gaBox\" data-row=\"$datarow\" data-col=\"$datacol\" data-sizex=\"$datasizex\" data-sizey=\"$datasizey\">
<div class=\"panel panel-default widget-wrapper\">
                      <div class=\"panel-headingx widget-title sectionHeader clearfix\">
                          <span class=\"pull-left\"><i class=\"fa fa-bar-chart\"></i> $wdgTitle</span>
                            <div class=\"widget-controls pull-right\">
                                <div class=\"btn-group\">
                                    <a href=\"#\" class=\"btn btn-default btn-xs panel-hide hide-full fa fa-minus\" data-id=\"$WidgetID\"></a>
                                </div>     
                            </div>
                      </div>
                      <div class=\"panel-body widget-stage sectionBody\" style=\"padding-top:0;overflow-y:hidden;\">
                      <div id=\"active-users\"></div><div style=\"width:100%;\" id=\"widgetSessions\"></div>
                      </div>
					  </div>
			</li>				
";

$e->output($WidgetOutput);
break;
return;
}
}
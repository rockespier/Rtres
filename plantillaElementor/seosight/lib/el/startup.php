<?php
require_once "sturtupBase.php";
class SeosightSEO {
	public $plugin_file=__FILE__;
	public $responseObj;
	public $licenseMessage;
	public $showMessage=false;
	public $slug="seosight";
	function __construct() {
		add_action( 'admin_print_styles', [ $this, 'SetAdminStyle' ] );
		$licenseKey=get_option("SeosightSEO_lic_Key","");
		$liceEmail=get_option( "SeosightSEO_lic_email","");
		$templateDir=get_stylesheet_directory(); //or dirname(__FILE__);
		if(SeosightSEOBase::CheckWPPlugin($licenseKey,$liceEmail,$this->licenseMessage,$this->responseObj,$templateDir."/style.css")){
			add_action( 'admin_menu', [$this,'ActiveAdminMenu'],99999);
			add_action( 'admin_post_SeosightSEO_el_deactivate_license', [ $this, 'action_deactivate_license' ] );
			//$this->licenselMessage=$this->mess;
			//***Write you plugin's code here***

		}else{
			if(!empty($licenseKey) && !empty($this->licenseMessage)){
				$this->showMessage=true;
			}
			update_option("SeosightSEO_lic_Key","") || add_option("SeosightSEO_lic_Key","");
			add_action( 'admin_post_SeosightSEO_el_activate_license', [ $this, 'action_activate_license' ] );
			add_action( 'admin_menu', [$this,'InactiveMenu']);
		}
        }
	function SetAdminStyle() {
		wp_register_style( "SeosightSEOLic", get_theme_file_uri("lib/el/_lic_style.css"),10);
		wp_enqueue_style( "SeosightSEOLic" );
	}
	function ActiveAdminMenu(){
		 
		add_menu_page (  "SeosightSEO", "Seosight License", "activate_plugins", $this->slug, [$this,"Activated"], " dashicons-star-filled ");
		//add_submenu_page(  $this->slug, "SeosightSEO License", "License Info", "activate_plugins",  $this->slug."_license", [$this,"Activated"] );

	}
	function InactiveMenu() {
		add_menu_page( "SeosightSEO", "Seosight License", 'activate_plugins', $this->slug,  [$this,"LicenseForm"], " dashicons-star-filled " );
		
	}
	function action_activate_license(){
		check_admin_referer( 'el-license' );
		$licenseKey=!empty($_POST['el_license_key'])?$_POST['el_license_key']:"";
		$licenseEmail=!empty($_POST['el_license_email'])?$_POST['el_license_email']:"";

		$import_demo_content_redirect = get_option('import_demo_content_redirect');
		if( $import_demo_content_redirect == 1 ) {
			update_option( 'import_demo_content_redirect', '' );
			$redirect_page = admin_url( 'themes.php?page=crum_auto_setup');
		} else {
			$redirect_page=!empty($_POST['redirect_page'])?$_POST['redirect_page']:admin_url( 'admin.php?page='.$this->slug);
		}

		update_option("SeosightSEO_lic_Key",$licenseKey) || add_option("SeosightSEO_lic_Key",$licenseKey);
		update_option("SeosightSEO_lic_email",$licenseEmail) || add_option("SeosightSEO_lic_email",$licenseEmail);
		update_option('_site_transient_update_themes','');
		wp_safe_redirect($redirect_page);
	}
	function action_deactivate_license() {
		check_admin_referer( 'el-license' );
		$message="";
		if(SeosightSEOBase::RemoveLicenseKey(__FILE__,$message)){
			update_option("SeosightSEO_lic_Key","") || add_option("SeosightSEO_lic_Key","");
			update_option('_site_transient_update_themes','');
		}
    	wp_safe_redirect(admin_url( 'admin.php?page='.$this->slug));
    }
	function Activated(){
		?>
        <form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
            <input type="hidden" name="action" value="SeosightSEO_el_deactivate_license"/>
            <div class="el-license-container">
                <h3 class="el-license-title"><i class="dashicons-before dashicons-star-filled"></i> <?php _e("Seosight License Info",'seosight');?> </h3>
                <hr>
                <ul class="el-license-info">
                <li>
                    <div>
                        <span class="el-license-info-title"><?php _e("Status",'seosight');?></span>

                        <?php if ( $this->responseObj->is_valid ) : ?>
                            <span class="el-license-valid"><?php _e("Valid",'seosight');?></span>
                        <?php else : ?>
                            <span class="el-license-valid"><?php _e("Invalid",'seosight');?></span>
                        <?php endif; ?>
                    </div>
                </li>

                <li>
                    <div>
                        <span class="el-license-info-title"><?php _e("License Type",'seosight');?></span>
                        <?php echo esc_html($this->responseObj->license_title); ?>
                    </div>
                </li>

               <li>
                   <div>
                       <span class="el-license-info-title"><?php _e("License Expired on",'seosight');?></span>
                       <?php echo esc_html($this->responseObj->expire_date);
                       if(!empty($this->responseObj->expire_renew_link)){
                           ?>
                           <a target="_blank" class="el-blue-btn" href="<?php echo esc_url($this->responseObj->expire_renew_link); ?>">Renew</a>
                           <?php
                       }
                       ?>
                   </div>
               </li>

                <li>
                    <div>
                        <span class="el-license-info-title"><?php _e("Your License Key",'seosight');?></span>
                        <span class="el-license-key"><?php echo esc_html( substr($this->responseObj->license_key,0,9)."XXXXXXXX-XXXXXXXX".substr($this->responseObj->license_key,-9) ); ?></span>
                    </div>
                </li>
                </ul>
                <div class="el-license-active-btn">
                    <?php wp_nonce_field( 'el-license' ); ?>
                    <?php submit_button('Deactivate'); ?>
                </div>
            </div>
        </form>
		<?php
	}
	
	function LicenseForm($redirect_p = '') {
        if($redirect_p == ''){
            $page_redirect = admin_url( 'admin.php?page='.$this->slug);
        } else {
            $page_redirect = $redirect_p;
        }
		?>
        <form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
            <input type="hidden" name="action" value="SeosightSEO_el_activate_license"/>
            <input type="hidden" name="redirect_page" value="<?php echo esc_url($page_redirect); ?>">
            <div class="el-license-container">
                <h3 class="el-license-title"><i class="dashicons-before dashicons-star-filled"></i> <?php _e("Seosight Theme Licensing",'seosight');?></h3>
                <hr>
				<?php
					if(!empty($this->showMessage) && !empty($this->licenseMessage)){
						?>
                        <div class="notice notice-error is-dismissible">
                            <p><?php echo esc_html($this->licenseMessage); ?></p>
                        </div>
						<?php
					}
				?>
                <p><?php _e("To activate the theme, install the demo data, and get full feature updates, please, enter your license key below.",'seosight');?></p>
    		    <div class="el-license-field">
    			    <label for="el_license_key"><?php _e("License Key:",'seosight');?></label>
    			    <input type="text" class="regular-text code" name="el_license_key" size="50" placeholder="xxxxxxxx-xxxxxxxx-xxxxxxxx-xxxxxxxx" required="required">
                    <div><small><?php 
                    printf(
                        __( 
                          'The license key is your Envato Purchase Code. <a target="_blank" href="%s">Where Is My Purchase Code?</a>', 
                          'seosight' 
                        ),
                        esc_url( 'https://help.market.envato.com/hc/en-us/articles/202822600-Where-Is-My-Purchase-Code-' )
                    );
                    ?></small></div>
                </div>
                <div class="el-license-field">
                    <label for="el_license_key"><?php _e("Email Address",'seosight');?></label>
                    <?php
                        $purchaseEmail   = get_option( "SeosightSEO_lic_email", get_bloginfo( 'admin_email' ));
                    ?>
                    <input type="text" class="regular-text code" name="el_license_email" size="50" value="<?php echo esc_attr($purchaseEmail); ?>" required="required">
                    <div><small><?php _e("We will send update news of this product by this email address, don't worry, we hate spam",'seosight');?></small></div>
                </div>
                <p>
                <?php
                printf(
                    __( 
                      'Have more questions? <a target="_blank" href="%s">Submit a Request</a> to get premium support.', 
                      'seosight' 
                    ),
                    esc_url( 'https://support.crumina.net/help-center/tickets/new' )
                  );
                ?>
                </p>
                <div class="el-license-active-btn">
					<?php wp_nonce_field( 'el-license' ); ?>
					<?php submit_button('Activate'); ?>
                </div>
            </div>
        </form>
		<?php
	}
}

new SeosightSEO();
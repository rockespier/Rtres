<?php if ( ! defined( 'FW' ) ) {
	die( 'Forbidden' );
}

class FW_Option_Type_Form_Builder_Item_Recaptcha_V3 extends FW_Option_Type_Form_Builder_Item {
    /**
     * The item type
     * @return string
     */
    public function get_type() {
		return 'recaptcha_v3';
    }

    /**
     * The boxes that appear on top of the builder and can be dragged down or clicked to create items
     * @return array
     */
    public function get_thumbnails() {
        $uri = fw_get_template_customizations_directory_uri('/extensions/forms/includes/builder-items/recaptchav3/static');
		return array(
			array(
				'html' =>
					'<div class="item-type-icon-title" data-hover-tip="' . __( 'Add a Recaptcha V3 field', 'seosight' ) . '">' .
					'<div class="item-type-icon"><img src="' . $uri . '/icon.png" /></div>' .
					'<div class="item-type-title">' . __( 'Recaptcha V3', 'seosight' ) . '</div>' .
					'</div>'
			)
		);
    }
    
    /**
     * Enqueue item type scripts and styles (in backend)
     */
    public function enqueue_static()
    {
        $uri = fw_get_template_customizations_directory_uri('/extensions/forms/includes/builder-items/recaptchav3/static');

        wp_enqueue_style(
            'fw-form-builder-item-type-recaptchav3',
            $uri .'/backend.css',
            array(),
            fw()->theme->manifest->get_version()
        );

        wp_enqueue_script(
            'fw-form-builder-item-type-recaptchav3',
            $uri .'/backend.js',
            array('fw-events'),
            fw()->theme->manifest->get_version(),
            true
        );

        fw()->backend->enqueue_options_static( $this->get_options() );
    }

    /**
	 * @since 1.0.2
	 */
	public function get_item_localization() {
		return array(
			'options'  => $this->get_options(),
			'l10n'     => array(
				'item_title' => __( 'Recaptcha V3', 'seosight' ),
				'label'      => __( 'Label', 'seosight' ),
				'edit_label' => __( 'Edit Label', 'seosight' ),
				'edit'       => __( 'Edit', 'seosight' ),
				'delete'     => __( 'Delete', 'seosight' ),
				'site_key'   => __( 'Set site key', 'seosight' ),
				'secret_key' => __( 'Set secret key', 'seosight' ),
			),
			'defaults' => array(
				'type'    => $this->get_type(),
				'options' => fw_get_options_values_from_input( $this->get_options(), array() )
			)
		);
	}

	private function get_options() {
		return array(
			'label_v3'     => array(
				'type'  => 'text',
				'label' => __( 'Label', 'seosight' ),
				'desc'  => __( 'Enter field label (it will be displayed on the web site)', 'seosight' ),
				'value' => __( 'Recaptcha V3', 'seosight' ),
			),
			'recaptcha_v3' => array(
				'type'  => 'recaptcha',
				'label' => false,
				'value' => null,
			)
		);
	}

    /**
     * Render item html for frontend form
     *
     * @param array $item Attributes from Backbone JSON
     * @param null|string|array $input_value Value submitted by the user
     * @return string HTML
     */
    public function frontend_render(array $item, $input_value)
    {
        $uri = fw_get_template_customizations_directory_uri('/extensions/forms/includes/builder-items/recaptchav3/static');
        $options = $item['options']['recaptcha_v3'];
        if( isset($options['site-key']) ){
			wp_enqueue_script( 'g-recaptcha-key-v3', "https://www.google.com/recaptcha/api.js?onload=fw_forms_builder_item_recaptcha_v3_init&render={$options['site-key']}", array( 'jquery' ), false, true );
            wp_enqueue_script( 'frontend-recaptcha-v3',
                $uri .'/frontend.js',
                array( 'jquery' ),
                fw()->theme->manifest->get_version(),
                true
            );
            wp_localize_script( 'frontend-recaptcha-v3', 'captcha_site_key', array('site_key' => $options['site-key']) );
            wp_localize_script( 'frontend-recaptcha-v3', 'fwAjaxUrl', admin_url( 'admin-ajax.php', 'relative' ));
        }

        return fw_render_view(
			$this->locate_path( '/views/view.php', dirname( __FILE__ ) . '/view.php' ),
			array(
				'item'  => $item,
				'label' => ( isset( $input_value['label'] ) ) ? $input_value['label'] : __( 'Security Code', 'seosight' ),
			)
		);
    }

    /**
     * Validate item on frontend form submit
     *
     * @param array $item Attributes from Backbone JSON
     * @param null|string|array $input_value Value submitted by the user
     * @return null|string Error message
     */
    public function frontend_validate(array $item, $input_value)
    {
        $messages = array(
            'not_success' => str_replace(
                array('{label}'),
                array($options['label']),
                __('Wrong captcha', 'seosight')
            ),
        );
        $options = $item['options']['recaptcha_v3'];
        $token = (isset($_POST['token'])) ? $_POST['token'] : '';
        if($token != ''){
			$captcha_secret_key = $options['secret-key'];
            $captcha_response = $this->returnReCaptcha($token, $captcha_secret_key);
            if ($captcha_response['success'] != 1){
				return $messages['not_success'];
			}
		}
    }

    public function returnReCaptcha( $token, $captcha_secret_key ){
		$recaptcha_url = 'https://www.google.com/recaptcha/api/siteverify';
        $recaptcha_get = wp_remote_get($recaptcha_url . '?secret=' . $captcha_secret_key . '&response=' . $token);
        $recaptcha = wp_remote_retrieve_body( $recaptcha_get );
		$recaptcha = json_decode($recaptcha, true);
		return $recaptcha;
	}
}

FW_Option_Type_Builder::register_item_type( 'FW_Option_Type_Form_Builder_Item_Recaptcha_V3' );
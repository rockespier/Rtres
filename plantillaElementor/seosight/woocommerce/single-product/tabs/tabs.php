<?php
/**
 * Single Product tabs
 *
 * This template can be overridden by copying it to yourtheme/woocommerce/single-product/tabs/tabs.php.
 *
 * HOWEVER, on occasion WooCommerce will need to update template files and you
 * (the theme developer) will need to copy the new files to your theme to
 * maintain compatibility. We try to do this as little as possible, but it does
 * happen. When this occurs the version of the template file will be bumped and
 * the readme will list any important changes.
 *
 * @see     https://woocommerce.com/document/template-structure/
 * @package WooCommerce\Templates
 * @version 9.6.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Filter tabs and allow third parties to add their own.
 *
 * Each tab is an array containing title, callback and priority.
 *
 * @see woocommerce_default_product_tabs()
 */
$product_tabs = apply_filters( 'woocommerce_product_tabs', array() );
$first = true;
if ( ! empty( $product_tabs ) ) : ?>
	<div class="product-description">
		<div class="container">
			<ul class="product-description-control" role="tablist">
				<?php foreach ( $product_tabs as $key => $product_tab ) :
					$active_class = ( $first === true ) ? 'active' : ''; ?>
					<li class="<?php echo esc_attr( $active_class . ' ' . $key ) ?>" id="tab-title-<?php echo esc_attr( $key ); ?>">
						<a href="#tab-<?php echo esc_attr( $key ); ?>" role="tab" data-toggle="tab" class="control-item">
							<?php echo wp_kses_post( apply_filters( 'woocommerce_product_' . $key . '_tab_title', $product_tab['title'], $key ) ); ?>
						</a>
					</li>
					<?php $first = false; ?>
				<?php endforeach; ?>
			</ul>
			<?php $first = true; ?>
			<div class="tab-content">
				<?php foreach ( $product_tabs as $key => $product_tab ) :
					$active_class = ( $first === true ) ? 'active' : ''; ?>
					<div role="tabpanel" class="tab-pane fade in <?php echo esc_attr( $active_class ) ?>" id="tab-<?php echo esc_attr( $key ); ?>">
						<div class="row">
							<div class="col-lg-12">
								<?php
								if ( isset( $product_tab['callback'] ) ) {
									call_user_func( $product_tab['callback'], $key, $product_tab );
								}
								$first = false;
								?>
							</div>
						</div>
					</div>
				<?php endforeach; ?>
				<?php do_action( 'woocommerce_product_after_tabs' ); ?>
			</div>
		</div>
	</div>

<?php endif; ?>

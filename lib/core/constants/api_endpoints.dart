class ApiEndpoints {
  // Backend API base URL (HTTPS to prevent 308 redirects)
  static const String baseUrl = 'https://api.veggofresh.in/api';

  //  endpoints
  static const String requestOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String userProfile = '/auth/me';
  static const String addToCart = '/customer/carts/items';
  static const String viewCart = '/customer/carts';
  static const String cartBadgeCount = '/customer/carts/badge-count';
  static const String checkoutSummary = '/customer/orders/checkout/summary';
  static const String deliverySlots = '/customer/orders/delivery-slots';
  static const String placeOrder = '/customer/orders';
  static const String verifyPayment = '/customer/orders/verify-payment';
  static const String orders = '/customer/orders';
  static String orderDetails(String id) => '/customer/orders/$id';
  static String orderTrack(String id) => '/customer/orders/$id/track';
  static String orderInvoice(String id) => '/customer/orders/$id/invoice';
  static String cancelOrder(String id) => '/customer/orders/$id/cancel';
  static String rateOrder(String id) => '/customer/orders/$id/rating';
  static String reorder(String id) => '/customer/orders/$id/reorder';
  static String updateCartItem(String id) => '/customer/carts/items/$id';
  static String deleteCartItem(String id) => '/customer/carts/items/$id';
  static const String wishlist = '/customer/wishlist';
  static String removeFromWishlist(String id) => '/customer/wishlist/$id';
  static const String addresses = '/customer/addresses';
  static const String shops = '/customer/shops';
  static const String categories = '/customer/categories';
  static const String banners = '/customer/banners';
  static const String products = '/customer/products';
  static const String productDeals = '/customer/products/deals';

  static String productDetails(String id) => '/customer/products/$id';
  static String relatedProducts(String id) => '/customer/products/$id/related';

  static String subcategories(String categoryId) =>
      '/customer/categories/$categoryId/subcategories';
  static const String googleMapsGeocodeApi =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const String googleMapsApiKey =
      'AIzaSyB-s6iI0DPblvyH-8qocSqi6yQo9vggXMs';

  // Razorpay API
  static const String razorpayKey = 'rzp_test_TTUpC17cOLtNl8';
}

class Api {
  // iconName 首页
  static const BASIC_URL = "http://192.168.0.119:3000/";

  static const LOGIN_URL = BASIC_URL + "/api/auth/login";

  static const REGISTER_URL = BASIC_URL + "/api/auth/register";

  static const INFO_URL = BASIC_URL + "/api/auth/info"; // user info using token

  static const USER_INFO_URL = BASIC_URL + "/api/user/info"; // user info using id

  static const UPLOAD_URL = BASIC_URL + "/api/auth/upload";

  static const MULTIPLEUPLOAD_URL = BASIC_URL + "/api/auth/multipleupload";

  static const NEWPOST_URL = BASIC_URL + "/api/userpost";

  static const USERPOSTINFO_URL = BASIC_URL + "/api/userpost/info";

  static const NEWMOMENTPOST_URL = BASIC_URL + "/api/momentpost";

  static const GETMOMENTPOST_URL = BASIC_URL + "/api/all/momentpost";//get all moment post

  static const NEWARTICLEPOST_URL = BASIC_URL + "/api/articlepost";

  static const GETFOLLOWER_URL = BASIC_URL + "/api/follower";

  static const GETFOLLOWING_URL = BASIC_URL + "/api/following";

  static const GETCATEGORY_URL = BASIC_URL + "/api/category";

  static const UPLOADFILE_URL = BASIC_URL + "/api/upload";

  static const USERPOST_COUNT_URL = BASIC_URL + "/api/userpost/count";

  static const LIKECOUNT_UPDATE_URL = BASIC_URL + "/api/update/moment/like";

  static const LIKE_CHECK_URL = BASIC_URL + "/api/like/record/check";

  static const LIKERECORD_URL = BASIC_URL + "/api/like/record";// add userid and postid to likerecord

  static const DELETELIKE_URL = BASIC_URL + "/api/like/record/delete/"; // delete likerecord field

  static const ADD_COMMENT_URL = BASIC_URL + "/api/comment/record";

  static const DELETE_COMMENT_URL = BASIC_URL + "/api/comment/record/delete/";

  static const GET_COMMENT_URL = BASIC_URL + "/api/comment/all";

  static const LIKE_COMMENT_UPDATE_URL = BASIC_URL + "/api/update/comment/like";

  static const DELETE_COMMENT_LIKE_RECORD_URL = BASIC_URL + "/api/comment/like/record/delete/";

  static const GET_COMMENT_COUNT_URL = BASIC_URL + "/api/comment/count";

  static const ADD_REPLY_URL = BASIC_URL + "/api/reply/record";

  static const GET_REPLY_URL = BASIC_URL + "/api/reply/all";

  static const GET_REPLY_COUNT_URL = BASIC_URL + "/api/reply/count";

  static const DELETE_REPLY_URL = BASIC_URL + "/api/reply/delete/";

  static const DELETE_REPLY_LIKE_URL = BASIC_URL + "/api/reply/like/delete/";

  static const UPDATE_REPLY_LIKE_URL = BASIC_URL + "/api/reply/like/update";

  static const ADD_FOLLOWER_URL = BASIC_URL + "/api/follower/add";

  static const DELETE_FOLLOWER_URL = BASIC_URL + "/api/follower/delete/";





}

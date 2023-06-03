import 'dart:convert';
import 'dart:io';
import 'package:dikouba_rawstart/model/annoncer_model.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/package_model.dart';
import 'package:dikouba_rawstart/model/post_model.dart';
import 'package:dikouba_rawstart/model/postcomment_model.dart';
import 'package:dikouba_rawstart/model/postfavourite_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/utils/DikoubaUtils.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

const BASE_URL = "https://dikouba-test.uc.r.appspot.com/"; //"https://us-central1-dikouba-test.cloudfunctions.net/";

BaseOptions options = new BaseOptions(
  baseUrl: BASE_URL,
  connectTimeout: Duration(milliseconds: 60000),
  receiveTimeout: Duration(milliseconds: 60000),
);
Dio dio = new Dio(options);

class API {
  static String TAG = "API";
  static int REGISTER_CATEGORY_ID = 3;
  static String BASE_URL_IMG = "http://spar.youmsi-tech.com/";

  static Future setDeviceToken(String id_users, device_token, device_os, action) {
    var mapBody = {
      "id_users": id_users,
      "device_token": device_token,
      "device_os": device_os,
      "action": action,
    };
    print("${TAG}:setDeviceToken ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "notifications_token_set",
      data: mapBody,
    );
  }

  static Future createAnnoncer(AnnoncerModel annoncerModel) {
    var mapBody = {
      "id_users": "${annoncerModel.id_users}",
      "checkout_phone_number": "${annoncerModel.checkout_phone_number}",
      "compagny": "${annoncerModel.compagny}",
      "picture_path": "${annoncerModel.picture_path}",
      "cover_picture_path": "",
    };
    print("${TAG}:createCustomer ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "create_annonceur",
      data: mapBody,
    );
  }

  static Future createEvent(EvenementModel evenementModel) {
    var mapBody = {
      "id_categories": "${evenementModel.id_categories}",
      "id_annoncers": "${evenementModel.id_annoncers}",
      "title": "${evenementModel.title}",
      "banner_path": "${evenementModel.banner_path}",
      "description": "${evenementModel.description}",
      "latitude": double.parse(evenementModel.latitude!),
      "longitude": double.parse(evenementModel.longitude!),
      "start_date": "${evenementModel.start_date_tmp}",
      "end_date": "${evenementModel.end_date_tmp}",
    };
    print("${TAG}:createEvent ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "create_evenement",
      data: mapBody,
    );
  }

  static Future updateEvent(EvenementModel evenementModel) {
    var mapBody = {
      "id_evenements": "${evenementModel.id_evenements}",
      "id_categories": "${evenementModel.id_categories}",
      "id_annoncers": "${evenementModel.id_annoncers}",
      "title": "${evenementModel.title}",
      "banner_path": "${evenementModel.banner_path}",
      "description": "${evenementModel.description}",
      "latitude": double.parse(evenementModel.latitude!),
      "longitude": double.parse(evenementModel.longitude!),
      "start_date": "${evenementModel.start_date_tmp}",
      "end_date": "${evenementModel.end_date_tmp}",
    };
    print("${TAG}:createEvent ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.put(
      "evenement_update_evenement",
      data: mapBody,
    );
  }

  static Future createPost(PostModel postModel) {
    var mapBody = {
      "type": "${postModel.type}",
      "id_evenements": "${postModel.id_evenements}",
      "media": "${postModel.media}",
      "description": "${postModel.description}",
    };
    print("${TAG}:createPost ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addpost",
      data: mapBody,
    );
  }

  static Future createPostComment(PostCommentModel postCommentModel) {
    var mapBody = {
      "id_users": "${postCommentModel.id_users}",
      "id_evenements": "${postCommentModel.id_evenements}",
      "id_posts": "${postCommentModel.id_posts}",
      "content": "${postCommentModel.content}",
    };
    print("${TAG}:createPostComment ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_post_addcomment",
      data: mapBody,
    );
  }

  static Future createPostFavourite(PostFavouriteModel postFavouriteModel) {
    var mapBody = {
      "id_users": "${postFavouriteModel.id_users}",
      "id_evenements": "${postFavouriteModel.id_evenements}",
      "id_posts": "${postFavouriteModel.id_posts}",
    };
    print("${TAG}:createPostComment ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_post_addlike",
      data: mapBody,
    );
  }

  static Future deleteEventPost(PostModel postModel) {
    var mapBody = {
      "id_evenements": "${postModel.id_evenements}",
      "id_posts": "${postModel.id_posts}",
    };
    print("${TAG}:deleteEventPost ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_deletepost",
      data: mapBody,
    );
  }

  static Future createSondage(SondageModel sondageModel) {
    var mapReponses = [];
    for (int i = 0; i < sondageModel.reponses.length; i++) {
      mapReponses.add({
        "description": "${sondageModel.reponses[i].description}",
        "valeur": "${sondageModel.reponses[i].valeur}"
      });
    }
    var mapBody = {
      "id_evenements": "${sondageModel.id_evenements}",
      "id_annoncers": "${sondageModel.id_annoncers}",
      "title": "${sondageModel.title}",
      "banner_path": "${sondageModel.banner_path}",
      "description": "${sondageModel.description}",
      "start_date": "${sondageModel.start_date_tmp}",
      "end_date": "${sondageModel.end_date_tmp}",
      "reponses": mapReponses,
    };
    print("${TAG}:createSondage ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "create_sondage",
      data: mapBody,
    );
  }

  static Future updateSondage(SondageModel sondageModel) {
    var mapBody = {
      "id_evenements": "${sondageModel.id_evenements}",
      "id_annoncers": "${sondageModel.id_annoncers}",
      "id_sondages": "${sondageModel.id_sondages}",
      "title": "${sondageModel.title}",
      "banner_path": "${sondageModel.banner_path}",
      "description": "${sondageModel.description}",
      "start_date": "${sondageModel.start_date_tmp}",
      "end_date": "${sondageModel.end_date_tmp}",
    };
    print("$TAG:updateSondage ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.put("sondage_update_sondage", data: mapBody);
  }

  static Future createEventSession(EvenementModel evenementModel) {
    var mapBody = {
      "id_categories": "${evenementModel.id_categories}",
      "id_annoncers": "${evenementModel.id_annoncers}",
      "parent_id": "${evenementModel.parent_id}",
      "title": "${evenementModel.title}",
      "banner_path": "${evenementModel.banner_path}",
      "description": "${evenementModel.description}",
      "latitude": double.parse(evenementModel.latitude!),
      "longitude": double.parse(evenementModel.longitude!),
      "start_date": "${evenementModel.start_date_tmp}",
      "end_date": "${evenementModel.end_date_tmp}",
    };
    print("${TAG}:createEventSession ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "create_evenement_session",
      data: mapBody,
    );
  }

  static Future createEventPackage(PackageModel packageModel) {
    var mapBody = {
      "id_evenements": "${packageModel.id_evenements}",
      "price": "${packageModel.price}",
      "name": "${packageModel.name}",
      "max_ticket_count": "${packageModel.max_ticket_count}",
    };
    print("${TAG}:createEventPackage ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addpackage",
      data: mapBody,
    );
  }

  static Future addTicketMobilePay(
      {required String idEvenement,
      required String idUser,
      required String idPackage,
      required String phoneNumber}) {
    var mapBody = {
      "id_evenements": "$idEvenement",
      "id_users": "$idUser",
      "id_packages": "$idPackage",
      "phone": "$phoneNumber",
    };
    print("${TAG}:addTicketMobilePay ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addticket_mobile_pay",
      data: mapBody,
    );
  }

  static Future retryMobilePay({required String idTickets, required String idUser, required String phoneNumber}) {
    var mapBody = {
      "id_tickets": "$idTickets",
      "id_users": "$idUser",
      "phone": "$phoneNumber",
    };
    print("${TAG}:retryTicketMobilePay ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_retry_mobile_pay",
      data: mapBody,
    );
  }

  static Future deleteTicket({required String idTickets, required String idUser}) {
    var mapBody = {
      "id_tickets": "$idTickets",
      "id_users": "$idUser",
    };
    print("${TAG}:deleteTicket ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_deleteticket",
      data: mapBody,
    );
  }

  static Future addTicket(
      {required String idEvenement, required String idUser, required String idPackage}) {
    var mapBody = {
      "id_evenements": "$idEvenement",
      "id_users": "$idUser",
      "id_packages": "$idPackage",
    };
    print("$TAG:addTicket ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addticket",
      data: mapBody,
    );
  }

  static Future checkTicketMobilePay({
    required String idTickets,
    required String idUser,
  }) {
    var mapBody = {
      "id_tickets": "$idTickets",
      "id_users": "$idUser",
    };
    print("${TAG}:checkTicketMobilePay ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_check_mobile_pay",
      data: mapBody,
    );
  }

  static Future checkTicketPaypalPay(
      {required String idTickets, required String idUser, required String orderId}) {
    var mapBody = {
      "id_tickets": "$idTickets",
      "id_users": "$idUser",
      "order_id": "$orderId"
    };
    print("${TAG}:checkTicketPaypalPay ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_check_paypal_pay",
      data: mapBody,
    );
  }

  static Future createUser(UserModel userModel) {
    var mapBody = {
      "uid": "${userModel.uid}",
      "name": "${userModel.name}",
      "email": "${userModel.email}",
      "phone": "${userModel.phone}",
      "password": "${userModel.password}",
      "email_verified": "${userModel.email_verified}",
      "photo_url": "${userModel.photo_url}",
    };
    print("${TAG}:createCustomer ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "create_user",
      data: mapBody,
    );
  }

  static Future updateUser(UserModel userModel) {
    var mapBody = {
      "uid": "${userModel.uid}",
      "name": "${userModel.name}",
      "email": "${userModel.email}",
      "phone": "${userModel.phone}",
      "photo_url": "${userModel.photo_url}",
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "update_user",
      data: mapBody,
    );
  }

  static Future findAllSession(List<String> idEvents) {
    var mapBody = {
      "id_evenements_list": idEvents,
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_evenement_allsessions",
      data: mapBody,
    );
  }

  static Future findUserItem(String idUser) {
    var mapBody = {
      "id_users": idUser,
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_item",
      data: mapBody,
    );
  }

  static Future findUserFollowers(String idUser) {
    var mapBody = {
      "id_users": idUser,
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findfollowers",
      data: mapBody,
    );
  }

  static Future findSondageItem(String idSondage) {
    var mapBody = {
      "id_sondages": idSondage,
    };
    print("${TAG}:findSondageItem ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_sondage_item",
      data: mapBody,
    );
  }

  static Future findUserFollowing(String idUser) {
    var mapBody = {
      "id_users": idUser,
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findfollowing",
      data: mapBody,
    );
  }

  static Future addFollower(String idUserFrom, String idUserTo) {
    var mapBody = {
      "id_users_from": idUserFrom,
      "id_users_to": idUserTo,
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_addfollower",
      data: mapBody,
    );
  }

  static Future deleteFollower(String idUserFrom, String idUserTo) {
    var mapBody = {
      "id_users_from": idUserFrom,
      "id_users_to": idUserTo,
    };
    print("${TAG}:updateUser ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_deletefollower",
      data: mapBody,
    );
  }

  static Future findEventFavoris(String idUser) {
    var mapBody = {
      "id_users": idUser,
    };
    // print("${TAG}:findEventFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findfavoris",
      data: mapBody,
    );
  }

  static Future findUserNotifications(String idUser) {
    var mapBody = {
      "id_users": idUser,
    };
    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "notifications_find_all",
      data: mapBody,
    );
  }

  static Future findEventItem(String idEvent, {required String idUser}) {
    var mapBody;
    if (idUser == null) {
      mapBody = {
        "id_evenements": idEvent,
      };
    } else {
      mapBody = {
        "id_evenements": idEvent,
        "id_users": idUser,
      };
    }

    // print("${TAG}:findEventFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_item",
      data: mapBody,
    );
  }

  static Future findEventParticipant(String idEvent) {
    var mapBody = {
      "id_evenements": idEvent,
    };
    // print("${TAG}:findEventFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_findparticipants",
      data: mapBody,
    );
  }

  static Future findEventPackage(String idEvent) {
    var mapBody = {
      "id_evenements": idEvent,
    };
    // print("${TAG}:findEventFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_findpackages",
      data: mapBody,
    );
  }

  static Future findPendingEvents() {
    var mapBody = {};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_evenement_pending",
      data: mapBody,
    );
  }

  static Future findUserLikes(String idUsers) {
    var mapBody = {"id_users": idUsers};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findlikes",
      data: mapBody,
    );
  }

  static Future findEventComments(String idEvent) {
    var mapBody = {"id_evenements": idEvent};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_findcomments",
      data: mapBody,
    );
  }

  static Future findUserComments(String idUsers) {
    var mapBody = {"id_users": idUsers};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findcomments",
      data: mapBody,
    );
  }

  static Future addEventComment(
      String idEvent, String idUsers, String comment) {
    var mapBody = {
      "id_evenements": idEvent,
      "id_users": idUsers,
      "content": comment,
    };

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addcomment",
      data: mapBody,
    );
  }

  static Future addLigneSondage(String idEvent, String idUsers,
      String idSondage, String idReponse, String valeur) {
    var mapBody = {
      "id_evenements": idEvent,
      "id_users": idUsers,
      "id_sondages": idSondage,
      "id_reponses": idReponse,
      "valeur": valeur,
    };
    print("${TAG}:addLigneSondage ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "create_lignesondage",
      data: mapBody,
    );
  }

  static Future findUserFavoris(String idUsers) {
    var mapBody = {"id_users": idUsers};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findfavoris",
      data: mapBody,
    );
  }

  static Future eventAddLike(String idUsers, String idEvent) {
    var mapBody = {
      "id_users": idUsers,
      "id_evenements": idEvent,
      "note": '5',
    };
    print("${TAG}:eventAddLike ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addlike",
      data: mapBody,
    );
  }

  static Future eventDeleteLike(String idUsers, String idEvent) {
    var mapBody = {
      "id_users": idUsers,
      "id_evenements": idEvent,
    };
    // print("${TAG}:eventAddLike ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_deletelike",
      data: mapBody,
    );
  }

  static Future eventAddFavoris(String idUsers, String idEvent) {
    var mapBody = {
      "id_users": idUsers,
      "id_evenements": idEvent,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_addfavoris",
      data: mapBody,
    );
  }

  static Future eventDeleteFavoris(String idUsers, String idEvent) {
    var mapBody = {
      "id_users": idUsers,
      "id_evenements": idEvent,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_deletefavoris",
      data: mapBody,
    );
  }

  static Future findEventsUser(String idUsers) {
    var mapBody = {
      "id_users": idUsers,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_deletefavoris",
      data: mapBody,
    );
  }

  static Future findSondageEvent(String idEvent) {
    var mapBody = {
      "id_evenements": idEvent,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_sondage_byevenement",
      data: mapBody,
    );
  }

  static Future findPostsEvent(String idEvent) {
    var mapBody = {
      "id_evenements": idEvent,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_posts_findall",
      data: mapBody,
    );
  }

  static Future findPostCommentsEvent(String idEvent, String idPosts) {
    var mapBody = {"id_evenements": idEvent, "id_posts": idPosts};
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_post_findcomments",
      data: mapBody,
    );
  }

  static Future findPostFavouritesEvent(String idEvent, String idPosts) {
    var mapBody = {"id_evenements": idEvent, "id_posts": idPosts};
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_post_findlike",
      data: mapBody,
    );
  }

  static Future findSondageUsers(String idUsers) {
    var mapBody = {
      "id_users": idUsers,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_sondage_byuser",
      data: mapBody,
    );
  }

  static Future findTicketsUsers(String idUsers) {
    var mapBody = {
      "id_users": idUsers,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "user_findtickets",
      data: mapBody,
    );
  }

  static Future scanTicketsUsers(String idUsers, String idTickets) {
    var mapBody = {
      "id_users": idUsers,
      "id_tickets": idTickets,
    };
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "evenement_ticket_setpresence",
      data: mapBody,
    );
  }

  static Future findInvitationsUserTagStatut(
      String idUsers, String tag, String statut) {
    var mapBody = {"id_users": idUsers, "tag": tag, "statut": statut};
    // print("${TAG}:eventAddFavoris ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_invitation_events",
      data: mapBody,
    );
  }

  static Future findEventsNearPosition(
      double lat, double lng, double radiusMeter) {
    var mapBody = {
      "latitude": lat,
      "longitude": lng,
      "distance": radiusMeter,
    };
    print("${TAG}:findEventsNearPosition ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_evenement_near",
      data: mapBody,
    );
  }

  static Future googleSearchAddress(String searchAddress) {
    BaseOptions optionsLocal = new BaseOptions(
      baseUrl: "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      connectTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 60000),
    );
    Dio dioLocal = new Dio(optionsLocal);

    var mapBody = {
      "input": searchAddress,
      "language": 'fr',
      "key": DikoubaUtils.MapApiKey,
    };
    print("${TAG}:googleSearchAddress ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dioLocal.get(
      "",
      queryParameters: mapBody,
    );
  }

  static Future googleAddressInfo(String placeId) {
    BaseOptions optionsLocal = new BaseOptions(
      baseUrl: "https://maps.googleapis.com/maps/api/place/details/json",
      connectTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 60000),
    );
    Dio dioLocal = new Dio(optionsLocal);

    var mapBody = {
      "place_id": placeId,
      "fields": 'address_components,geometry,formatted_address,place_id',
      "key": DikoubaUtils.MapApiKey,
    };
    print("${TAG}:googleSearchAddress ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dioLocal.get(
      "",
      queryParameters: mapBody,
    );
  }

  static Future googleCoordinateInfo(double latitude, longitude) {
    BaseOptions optionsLocal = new BaseOptions(
      baseUrl: "https://maps.google.com/maps/api/geocode/json",
      connectTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 60000),
    );
    Dio dioLocal = new Dio(optionsLocal);

    var mapBody = {
      "latlng": '$latitude,$longitude',
      "fields": 'address_components,geometry,formatted_address,place_id',
      "key": DikoubaUtils.MapApiKey,
    };
    print("${TAG}:googleSearchAddress ${json.encode(mapBody)}");

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dioLocal.get(
      "",
      queryParameters: mapBody,
    );
  }

  static Future findSoonEvents() {
    var mapBody = {};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_evenement_soon",
      data: mapBody,
    );
  }

  static Future findEndedEvents() {
    var mapBody = {};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_evenement_ended",
      data: mapBody,
    );
  }

  static Future findSondages() {
    var mapBody = {};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_sondage",
      data: mapBody,
    );
  }

  static Future findSondagesByAnnoncer(String annoncerID) {
    var mapBody = {"id_annoncers": annoncerID};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_sondage",
      data: mapBody,
    );
  }

  static Future findAllEvents() {
    var mapBody = {};

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.post(
      "find_evenement",
      data: mapBody,
    );
  }

  static Future findAllCategories() {

    // dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio.get(
      "categories",
    );
  }

  static Future<String?> downloadFileFromUrl(
      String url, String fileName, void Function(int, int) showDownloadProgress) async {
    Dio dio = new Dio();
    var tempDir = await getTemporaryDirectory();
    String fullPath = tempDir.path + "/${fileName}";
    print('full path ${fullPath}');

    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);
      File file = File(fullPath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();

      return fullPath;
    } catch (e) {
      print("$TAG:download2 ${e}");
      return null;
    }
  }
}

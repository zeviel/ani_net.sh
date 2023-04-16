#!/bin/bash

api="https://api.aninetapi.com/api"
core_api="https://aninetcore-4pkyzhmcba-ew.a.run.app/api"
user_id=0
token=null
user_agent="Dart/2.13 (dart:io)"

function login() {
	# 1 - email: (string): <email>
	# 2 - password: (string): <password>
	response=$(curl --request POST \
		--url "$core_api/Login" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--data "email=$1&password=$2")
	if [ -n $(jq -r ".token" <<< "$response") ]; then
		token=$(jq -r ".token" <<< "$response")
		user_id=$(jq -r ".userId" <<< "$response")
	fi
	echo $response
}

function register() {
	# 1 - name: (string): <name>
	# 2 - password: (string): <password?
	# 3 - email: (string): <email>
	# 4 - gender_id: (integer): <1 - male, 2 - female - default: 1>
	# 5 - avatar_id: (integer): <avatar_id - default: 1>
	# 6 - google: (boolean): <true, false - default: false>
	curl --request POST \
		--url "$core_api/Register" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--data "name=$1&password=$2&email=$3&genderId=${4:-1}&avatarId=${5:-1}&google=${6:-false}"
}

function get_user_favorite_animes() {
	# 1 - user_id: (integer): <user_id>
	# 2 - count: (integer): <count - default: 10>
	# 3 - skip: (integer): <skip - default: 0>
	curl --request GET \
		--url "$api/GetUserFavoriteAnimes?userId=$1&count=${2:-10}&skip=${3:-0}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_anime_list() {
	# 1 - sort: (string): <sort - default: popularity>
	# 2 - genre: (string): <genre - default: null>
	# 3 - type: (string): <type - default: ova,tv,movie>
	# 4 - status: (string): <status - default: anons>
	# 5 - count: (integer): <count - default: 10>
	# 6 - skip: (integer): <skip - default: 0>
	# 7 - only_new: (boolean): <true, false - default: false>
	# 8 - has_video: (boolean): <true, false - default: false>
	# 9 - translation: (string): <translation - default: ru>
	curl --request GET \
		--url "$api/ListAnime?sort=${1:-popularity}&genre=${2:-}&type=${3:-ova,tv,movie}&status=${4:-anons}&count=${5:-10}&skip=${6:-0}&userId=$user_id&onlyNew=${7:-false}&hasVideo=${8:-false}&translation=${9:-ru}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_notifications() {
	# 1 - count: (integer): <count - default: 50>
	# 2 - skip: (integer): <skip - default: 0>
	# 3 - is_english: (boolean): <true, false - default: false>
	curl --request GET \
		--url "$api/GetFavoriteLog?userId=$user_id&count=${1:-50}&skip=${2:-0}&isEnglish=${3:-false}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_anime_description() {
	# 1 - anime_id: (integer): <anime_id>
	# 2 - translation: (string): <translation - default: ru>
	# 3 - is_blocked: (boolean): <true, false - default: false>
	# 4 - show_all_videos: (boolean): <true, false - default: true>
	curl --request GET \
		--url "$api/GetDescription?id=$1&userId=$user_id&translation=${2:-ru}&isBlocked=${3:-false}&showAllVideos=${4:-true}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_anime_comments() {
	# 1 - anime_id: (integer): <anime_id>
	# 2 - translation: (string): <translation - default: ru>
	curl --request GET \
		--url "$api/AnimeCommentsForList?id=$1&userId=$user_id&translation=${2:-ru}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function comment_manga() {
	# 1 - anime_id: (integer): <anime_id>
	# 2 - text: (string): <text>
	# 3 - translation: (string): <translation - default: ru>
	# 4 - is_spoiler: (boolean): <true, false default: false>
	curl --request POST \
		--url "$core_api/Comments" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--header "authorization: bearer $token" \
		--data "animeId=$1&userId=$user_id&text=$2&translation=${3:-ru}&ContainsSpoilers=${4:-false}"
}

function like_comment() {
	# 1 - comment_id: (integer): <comment_id>
	# 2 - is_like: (boolean): <true, false default: true>
	curl --request POST \
		--url "$core_api/AddLike?commentId=$1&userId=$user_id&like=${2:-true}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "authorization: bearer $token"
}

function get_user_info() {
	# 1 - user_id: (integer): <user_id>
	curl --request GET \
		--url "$api/User?id=$1" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_user_specific_list() {
	# 1 - list_type: (string): <list_type - default: completed>
	# 2 - user_id: (integer): <user_id>
	# 3 - count: (integer): <count - default: 10>
	# 4 - order: (string): <order - default: latest>
	curl --request GET \
		--url "$api/SpecificList?listType=${1:-completed}&userId=$2&count=${3:-10}&order=${4:-latest}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_user_friends() {
	# 1 - user_id: (integer): <user_id>
	curl --request GET \
		--url "$api/Friend?id=$1" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_user_pentagram() {
	# 1 - user_id: (integer): <user_id>
	curl --request GET \
		--url "$api/GetPentagram?userId=$1" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function send_friend_request() {
	# 1 - user_id: (integer): <user_id>
	curl --request POST \
		--url "$core_api/AddPendingFriend?userId=$user_id&friendId=$1" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "authorization: bearer $token"
}

function get_friend_suggestings() {
	# 1 - count: (integer): <count - default: 1000>
	curl --request GET \
		--url "$api/UserSuggested?userId=$user_id&count=${1:-1000}" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "authorization: bearer $token"
}

function get_account_info() {
	curl --request GET \
		--url "$api/User?id=$user_id" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function change_profile_info() {
	# 1 - name: (string): <name - default: account_name>
	# 2 - gender_id: (integer): <gender_id - default: account_gender_id>
	# 3 - avatar_id: (integer): <avatar_id - default: account_avatar_id>
	account_info=$(get_account_info)
	curl --request POST \
		--url "$core_api/ChangeUserInformation?userId=$user_id" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--header "authorization: bearer $token" \
		--data "name=${1:-$(jq -r ".name" <<< "$account_info")}&genderId=${2:-$(jq -r ".gender.genderId" <<< "$account_info")}&avatarId=${1:-$(jq -r ".avatarId" <<< "$account_info")}"
}

function change_password() {
	# 1 - old_password: (string): <old_password>
	# 2 - new_password: (string): <new_password>
	curl --request POST \
		--url "$core_api/ChangePassword" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--header "authorization: bearer $token" \
		--data "userId=$user_id&oldPassword=$1&newPassword=$2"
}

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
    <title>네이버 api를 이용한 길찾기</title>
    <script type="text/javascript" src="https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=nn9o99r7mj"></script>
    <script type="text/javascript" src="https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=nn9o99r7mj&amp;submodules=panorama,geocoder,drawing,visualization"></script>
    <script src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript" src="http://code.jquery.com/jquery-2.2.4.min.js"></script>
    <style type="text/css">
        #map .buttons { position:absolute;top:0;left:0;z-index:1000;padding:5px; }
        #map .buttons .control-btn { margin:0 5px 5px 0; }
        #map .btn_mylct{z-index:100;overflow:hidden;display:inline-block;position:absolute;top:7px;left:5px;width:34px;height:34px;border:1px solid rgba(58,70,88,.45);border-radius:2px;background:#fcfcfd;text-align:center;-webkit-background-clip:padding;background-clip:padding-box}
        #map .spr_trff{overflow:hidden;display:inline-block;color:transparent!important;vertical-align:top;background:url(https://ssl.pstatic.net/static/maps/m/spr_trff_v6.png) 0 0;background-size:200px 200px;-webkit-background-size:200px 200px}
        #map .spr_ico_mylct{width:20px;height:20px;margin:7px 0 0 0;background-position:-153px -31px}
        .search { position:absolute; z-index:1000; top:20px; left:20px;}
        .search #address { width:150px; height:20px; line-height:20px; border:solid 1px #555; padding:5px; font-size:12px; box-sizing:content-box; }
        .search #submit { height:30px;line-height:30px;padding:0 10px;font-size:12px;border:solid 1px #555;border-radius:3px;cursor:pointer;box-sizing:content-box; }
    </style>
</head>
<body>
<div id="map" style="width:100%;height:520px;">
	<div class="search" style="">
		<input id="address" type="text" placeholder="검색할 주소" value="가마산로 245" />
		<input id="submit" type="button" value="주소 검색" />
	</div>
</div>
<div class="buttons">
    <input id="interaction" type="button" name="지도 인터렉션" value="지도 인터렉션" class="control-btn" />
    <input id="kinetic" type="button" name="관성 드래깅" value="관성 드래깅" class="control-btn" />
    <!-- <input id="tile-transition" type="button" name="타일 fadeIn 효과" value="타일 fadeIn 효과" class="control-btn" /> -->
    <input id="controls" type="button" name="모든 지도 컨트롤" value="모든 지도 컨트롤" class="control-btn" />
    <input id="min-max-zoom" type="button" name="최소/최대 줌 레벨" value="최소/최대 줌 레벨: 10 ~ 21" class="control-btn" />
    <input id="remove" type="button" value="폴리라인 삭제" class="btn" />
    <input id="street" type="button" value="거리뷰" class="control-btn control-on" />
</div>
<form id="search-form">
	<label for="start-point">출발지:</label>
	<input type="text" id="start-point" name="start-point"><br>
	<label for="end-point">도착지:</label>
	<input type="text" id="end-point" name="end-point"><br>
	<button type="button" id="btn-search">검색</button>
</form>
<div id="result"></div>
<div id="pano" style="width:100%;height:300px;"></div>

<script>
//지도 생성 시에 옵션을 지정할 수 있습니다.
var map = new naver.maps.Map('map', {
        center: new naver.maps.LatLng(37.4954644, 126.8875386), //지도의 초기 중심 좌표
        zoom: 13, //지도의 초기 줌 레벨
        minZoom: 7, //지도의 최소 줌 레벨
        mapTypeControl: true,
        mapTypeControlOptions:{
            style: naver.maps.MapTypeControlStyle.DROPDOWN},
        zoomControl: true, //줌 컨트롤의 표시 여부
        zoomControlOptions: { //줌 컨트롤의 옵션
            position: naver.maps.Position.TOP_RIGHT
        }
});
    // 거리뷰 레이어를 생성합니다.
    var streetLayer = new naver.maps.StreetLayer();
    // 거리뷰 버튼에 이벤트를 바인딩합니다.
    var btn = $('#street');
	//레이어컨트롤
    naver.maps.Event.addListener(map, 'streetLayer_changed', function(streetLayer){
    if (streetLayer){
        btn.addClass('control-on');
    }else{
        btn.removeClass('control-on');
    }
});
	//버튼 클릭 이벤트
btn.on("click", function(e) {
    e.preventDefault();

    // 거리뷰 레이어가 지도 위에 있으면 거리뷰 레이어를 지도에서 제거하고,
    // 거리뷰 레이어가 지도 위에 없으면 거리뷰 레이어를 지도에 추가합니다.
    if (streetLayer.getMap()) {
        streetLayer.setMap(null);
    } else {
        streetLayer.setMap(map);
    }
});
	
//setOptions 메서드를 이용해 옵션을 조정할 수도 있습니다.
map.setOptions("mapTypeControl", true); //지도 유형 컨트롤의 표시 여부

naver.maps.Event.addListener(map, 'zoom_changed', function (zoom) {
    console.log('zoom:' + zoom);
});

map.setOptions('minZoom', 10);
console.log('잘못된 참조 시점', map.getOptions('minZoom'), map.getOptions('minZoom') === 10);

// 지도의 옵션 참조는 init 이벤트 이후에 참조해야 합니다.
naver.maps.Event.once(map, 'init', function () {
    console.log('올바른 참조 시점', map.getOptions('minZoom') === 10);
    //map 기능
    streetLayer.setMap(map);

    var locationBtnHtml = '<a href="#" class="btn_mylct"><span class="spr_trff spr_ico_mylct">내 위치</span></a>';
        
    var $locationBtn = $(locationBtnHtml),
        locationBtnEl = $locationBtn[0];

    map.controls[naver.maps.Position.LEFT_CENTER].push(locationBtnEl);
    naver.maps.Event.addDOMListener(locationBtnEl, 'click', function(){
        if (navigator.geolocation) {
            /**
             * navigator.geolocation 은 Chrome 50 버젼 이후로 HTTP 환경에서 사용이 Deprecate 되어 HTTPS 환경에서만 사용 가능 합니다.
             * http://localhost 에서는 사용이 가능하며, 테스트 목적으로, Chrome 의 바로가기를 만들어서 아래와 같이 설정하면 접속은 가능합니다.
             * chrome.exe --unsafely-treat-insecure-origin-as-secure="http://example.com"
             */
            navigator.geolocation.getCurrentPosition(onSuccessGeolocation, onErrorGeolocation);
        } else {
            var center = map.getCenter();
/*             infowindow.setContent('<div style="padding:20px;"><h5 style="margin-bottom:5px;color:#f00;">Geolocation not supported</h5></div>');
            infowindow.open(map, center); */
        }
    });
});

function onSuccessGeolocation(position) {
    var location = new naver.maps.LatLng(position.coords.latitude,
                                        position.coords.longitude);

    map.setCenter(location); // 얻은 좌표를 지도의 중심으로 설정합니다.
    map.setZoom(13); // 지도의 줌 레벨을 변경합니다.
    console.log('현재 나의 위치: ' + location.toString());
}

function onErrorGeolocation() {
	var center = map.getCenter();

    infowindow.setContent('<div style="padding:10px;">' + '<h5 style="margin-bottom:5px;color:#f00;">Geolocation failed!</h5>'+ "latitude: "+ center.lat() +"<br />longitude: "+ center.lng() +'</div>');

    infowindow.open(map, center);
}


// 지도 인터랙션 옵션
$("#interaction").on("click", function(e) {
    e.preventDefault();

    if (map.getOptions("draggable")) {
        map.setOptions({ //지도 인터랙션 끄기
            draggable: false,
            pinchZoom: false,
            scrollWheel: false,
            keyboardShortcuts: false,
            disableDoubleTapZoom: true,
            disableDoubleClickZoom: true,
            disableTwoFingerTapZoom: true
        });
        $(this).removeClass("control-on");
    } else {
        map.setOptions({ //지도 인터랙션 켜기
            draggable: true,
            pinchZoom: true,
            scrollWheel: true,
            keyboardShortcuts: true,
            disableDoubleTapZoom: false,
            disableDoubleClickZoom: false,
            disableTwoFingerTapZoom: false
        });
        $(this).addClass("control-on");
    }
});

// 관성 드래깅 옵션
$("#kinetic").on("click", function(e) {
    e.preventDefault();

    if (map.getOptions("disableKineticPan")) {
        map.setOptions("disableKineticPan", false); //관성 드래깅 켜기
        $(this).addClass("control-on");
    } else {
        map.setOptions("disableKineticPan", true); //관성 드래깅 끄기
        $(this).removeClass("control-on");
    }
});

// 타일 fadeIn 효과
/* $("#tile-transition").on("click", function(e) {
    e.preventDefault();

    if (map.getOptions("tileTransition")) {
        map.setOptions("tileTransition", false); //타일 fadeIn 효과 끄기

        $(this).removeClass("control-on");
    } else {
        map.setOptions("tileTransition", true); //타일 fadeIn 효과 켜기
        $(this).addClass("control-on");
    }
}); */

//min/max 줌 레벨
$("#min-max-zoom").on("click", function(e) {
	e.preventDefault();
	if (map.getOptions("minZoom") === 10) {
		map.setOptions({
			minZoom: 7,
			maxZoom: 21
		});
		$(this).val(this.name + ': 7 ~ 21');
	} else {
		map.setOptions({
			minZoom: 10,
			maxZoom: 21
		});
		$(this).val(this.name + ': 10 ~ 21');
	}
});

//지도 컨트롤
$("#controls").on("click", function(e) {
	e.preventDefault();
	if (map.getOptions("scaleControl")) {
		map.setOptions({ //모든 지도 컨트롤 숨기기
			scaleControl : false,
			logoControl : false,
			mapDataControl : false,
			zoomControl : false,
			mapTypeControl : false
		});
		$(this).removeClass('control-on');
	} else {
		map.setOptions({ //모든 지도 컨트롤 보이기
			scaleControl : true,
			logoControl : true,
			mapDataControl : true,
			zoomControl : true,
			mapTypeControl : true
		});
		$(this).addClass('control-on');
	}
});

$("#interaction, #tile-transition, #controls").addClass("control-on");

// 좌표로 길찾기 검색 버튼 클릭
$('#btn-search').on("click",function(event) {
	event.preventDefault(); 
	var startAddr = $('#start-point').val(); // 출발지 주소
	var endAddr = $('#end-point').val(); // 도착지 주소

	// 츨발지 지오코딩
	let startPoint, endPoint;
	naver.maps.Service.geocode({
				query : startAddr
			}, function(status, response) {
		if (status === naver.maps.Service.Status.ERROR) {
			return alert('Something Wrong!');
		}
		if (response.v2.meta.totalCount === 0) {
			return alert('totalCount' + response.v2.meta.totalCount);
		}
		var item = response.v2.addresses[0], startPoint = new naver.maps.LatLng(item.x, item.y);
		naver.maps.Service.geocode({ query : endAddr }, function(status, response) {
			if (status === naver.maps.Service.Status.ERROR) {
				return alert('Something Wrong!');
			}
			if (response.v2.meta.totalCount === 0) {
				return alert('totalCount' + response.v2.meta.totalCount);
			}
			var item = response.v2.addresses[0], endPoint = new naver.maps.LatLng( item.x, item.y);
			console.log("startPoint: " + startPoint + ", endPoint: " + endPoint);
			var usrStr = encodeURIComponent("https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=" + startPoint.y + "," + startPoint.x + "&goal=" + endPoint.y + "," + endPoint.x);
			var url = '/proxy.do?urlStr=' + usrStr;
			$.ajax({
				url : url,
				type : 'GET',
				success : function(response) {
					var path = response.route.traoptimal[0].path;
					var points = path.map(function(point) {
								return new naver.maps.LatLng(point[1],point[0]);
					});
					var polyline = new naver.maps.Polyline({
						map : map,
						path : points,
						strokeColor : '#ff0000',
						strokeStyle : 'shortdash',
						strokeLineCap : 'round',
						startIcon : 3,
						startIconSize : 10,
						endIcon : 1,
						endIconSize : 12,
						strokeWeight : 5,
						strokeOpacity : 0.5
					});
					$('#remove').on("click", function() {
						if (polyline){
							polyline.setMap(null);
						}
					})
				}, error : function( xhr, status, error) {
					$('#result').text('검색에 실패했습니다: '+ error);
				}
			});
		});
	});
});
/////////
/////////
/////////
var infoWindow = new naver.maps.InfoWindow({
    anchorSkew: true
});

map.setCursor('pointer');

function searchCoordinateToAddress(latlng) {

    infoWindow.close();

    naver.maps.Service.reverseGeocode({
        coords: latlng,
        orders: [
            naver.maps.Service.OrderType.ADDR,
            naver.maps.Service.OrderType.ROAD_ADDR
        ].join(',')
    }, function(status, response) {
        if (status === naver.maps.Service.Status.ERROR) {
            return alert('Something Wrong!');
        }

        var items = response.v2.results,
            address = '',
            htmlAddresses = [];

        for (var i=0, ii=items.length, item, addrType; i<ii; i++) {
            item = items[i];
            address = makeAddress(item) || '';
            addrType = item.name === 'roadaddr' ? '[도로명 주소]' : '[지번 주소]';

            htmlAddresses.push((i+1) +'. '+ addrType +' '+ address);
        }

        infoWindow.setContent([
            '<div style="padding:10px;min-width:200px;line-height:150%;">',
            '<h4 style="margin-top:5px;">검색 좌표</h4><br />',
            htmlAddresses.join('<br />'),
            '</div>'
        ].join('\n'));

        infoWindow.open(map, latlng);
    });
}

function searchAddressToCoordinate(address) {
    naver.maps.Service.geocode({
        query: address
    }, function(status, response) {
        if (status === naver.maps.Service.Status.ERROR) {
            return alert('Something Wrong!');
        }

        if (response.v2.meta.totalCount === 0) {
            return alert('totalCount' + response.v2.meta.totalCount);
        }

        var htmlAddresses = [],
            item = response.v2.addresses[0],
            point = new naver.maps.Point(item.x, item.y);

        if (item.roadAddress) {
            htmlAddresses.push('[도로명 주소] ' + item.roadAddress);
        }

        if (item.jibunAddress) {
            htmlAddresses.push('[지번 주소] ' + item.jibunAddress);
        }

        if (item.englishAddress) {
            htmlAddresses.push('[영문명 주소] ' + item.englishAddress);
        }

        infoWindow.setContent([
            '<div style="padding:10px;min-width:200px;line-height:150%;">',
            '<h4 style="margin-top:5px;">검색 주소 : '+ address +'</h4><br />',
            htmlAddresses.join('<br />'),
            '</div>'
        ].join('\n'));

        map.setCenter(point);
        infoWindow.open(map, point);
    });
}

function initGeocoder() {
    map.addListener('click', function(e) {
        searchCoordinateToAddress(e.coord);
        
        if (streetLayer.getMap()) {
            var latlng = e.coord;

            // 파노라마의 setPosition()은 해당 위치에서 가장 가까운 파노라마(검색 반경 300미터)를 자동으로 설정합니다.
            pano.setPosition(latlng);
        }
    });

    $('#address').on('keydown', function(e) {
        var keyCode = e.which;

        if (keyCode === 13) { // Enter Key
            searchAddressToCoordinate($('#address').val());
        }
    });

    $('#submit').on('click', function(e) {
        e.preventDefault();

        searchAddressToCoordinate($('#address').val());
    });

    searchAddressToCoordinate('가마산로 245');
}

function makeAddress(item) {
    if (!item) {
        return;
    }

    var name = item.name,
        region = item.region,
        land = item.land,
        isRoadAddress = name === 'roadaddr';

    var sido = '', sigugun = '', dongmyun = '', ri = '', rest = '';

    if (hasArea(region.area1)) {
        sido = region.area1.name;
    }

    if (hasArea(region.area2)) {
        sigugun = region.area2.name;
    }

    if (hasArea(region.area3)) {
        dongmyun = region.area3.name;
    }

    if (hasArea(region.area4)) {
        ri = region.area4.name;
    }

    if (land) {
        if (hasData(land.number1)) {
            if (hasData(land.type) && land.type === '2') {
                rest += '산';
            }

            rest += land.number1;

            if (hasData(land.number2)) {
                rest += ('-' + land.number2);
            }
        }

        if (isRoadAddress === true) {
            if (checkLastString(dongmyun, '면')) {
                ri = land.name;
            } else {
                dongmyun = land.name;
                ri = '';
            }

            if (hasAddition(land.addition0)) {
                rest += ' ' + land.addition0.value;
            }
        }
    }

    return [sido, sigugun, dongmyun, ri, rest].join(' ');
}

function hasArea(area) {
    return !!(area && area.name && area.name !== '');
}

function hasData(data) {
    return !!(data && data !== '');
}

function checkLastString (word, lastString) {
    return new RegExp(lastString + '$').test(word);
}

function hasAddition (addition) {
    return !!(addition && addition.value);
}

naver.maps.onJSContentLoaded = initGeocoder;
</script>

<script>
var position = new naver.maps.LatLng(37.4954644, 126.8875386);
var pano = null;

var panoramaOptions = {
	position : new naver.maps.LatLng(37.4954644, 126.8875386),
	size : new naver.maps.Size(800, 600),
	pov : {
		pan : -135,
		tilt : 29,
		fov : 100
	}
};

function initPanorama() {
	pano = new naver.maps.Panorama("pano", {
		position : new naver.maps.LatLng(37.4954644,
				126.8875386),
		pov : {
			pan : -135,
			tilt : 29,
			fov : 100
		},
		zoomControl : true,
		zoomControlOptions : {
			position : naver.maps.Position.TOP_RIGHT,
			style : naver.maps.ZoomControlStyle.SMALL
		}
	});
}

window.addEventListener('load', function() {
	  initPanorama();
	});

$("#zoom").on("click", function(e) {
	e.preventDefault();

	var el = $(this), zoomControlEnabled = pano.getOptions("zoomControl");

	if (!zoomControlEnabled) {
		pano.setOptions({
			zoomControl : true
		});
		el.val("ZoomControl 끄기").addClass("control-on");
	} else {
		pano.setOptions({
			zoomControl : false
		});
		el.val("ZoomControl 켜기").removeClass("control-on");
	}
});
</script>
</body>
</html>
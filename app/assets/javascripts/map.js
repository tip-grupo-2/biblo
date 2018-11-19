initMap = function() {
    var input = document.getElementById('address');
    var map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: -34.705274, lng: -58.278358},
        zoom: 15
    });
    var card = document.getElementById('pac-card');
    var types = document.getElementById('changetype-address');

    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(card);

    var autocomplete = new google.maps.places.Autocomplete(input);

    autocomplete.setFields(
        ['address_components', 'geometry', 'icon', 'name']);

    var infowindow = new google.maps.InfoWindow();
    var infowindowContent = document.getElementById('infowindow-content');
    infowindow.setContent(infowindowContent);
    var marker = new google.maps.Marker({
        map: map,
        anchorPoint: new google.maps.Point(0, -29)
    });
    autocomplete.addListener('place_changed', function() {
        marker.setVisible(false);
        var place = autocomplete.getPlace();
        if (!place.geometry) {
            window.alert("No details available for input: '" + place.name + "'");
            return;
        }
        if (place.geometry.viewport) {
            map.fitBounds(place.geometry.viewport);
        } else {
            map.setCenter(place.geometry.location);
            map.setZoom(17);
        }
        marker.setPosition(place.geometry.location);
        marker.setVisible(true);
        var lat = document.getElementById("latitude")
        lat.value = place.geometry.location.lat();
        var lng = document.getElementById("longitude")
        lng.value = place.geometry.location.lng();

        // event for updating location in user
        if(document.getElementById('latitude')) {
            document.getElementById('latitude').value = place.geometry.location.lat();
            document.getElementById('longitude').value = place.geometry.location.lng();
        }

        var address = '';
        if (place.address_components) {
            address = [
                (place.address_components[0] && place.address_components[0].short_name || ''),
                (place.address_components[1] && place.address_components[1].short_name || ''),
                (place.address_components[2] && place.address_components[2].short_name || '')
            ].join(' ');
        }

        infowindowContent.children['place-icon'].src = place.icon;
        infowindowContent.children['place-name'].textContent = place.name;
        infowindowContent.children['place-address'].textContent = address;
        infowindow.open(map, marker);
    });
}

initStaticGeoCodeMap = function(){
    var address = document.getElementById('address');
    $.getJSON(`https://maps.googleapis.com/maps/api/geocode/json?address=${urlizeString(address.textContent)}&key=AIzaSyA7FZ14h7xhNNN5QmXt5lJpzPArNjvNfOQ`, function success(response){
    })
    .then(data => {
        var locatedAt = data.results[0].geometry.location;
        var map = new google.maps.Map(document.getElementById('map'), {
            center: {lat: locatedAt.lat, lng: locatedAt.lng},
            zoom: 15
        });
        var infowindow = new google.maps.InfoWindow();
        var infowindowContent = document.getElementById('infowindow-content');
        infowindow.setContent(infowindowContent);
        var marker = new google.maps.Marker({
            map: map,
            anchorPoint: new google.maps.Point(0, -29)
        });
        marker.setPosition(locatedAt);
        marker.setVisible(true);
        infowindowContent.children['place-address'].textContent = address.textContent;
        infowindow.open(map, marker);
    });
};

urlizeString = function(string){
    return string.replace(" ","+");
};

initStaticGeoCodeMapWithZone = function(){
    var address = document.getElementById('address');
    $.getJSON(`https://maps.googleapis.com/maps/api/geocode/json?address=${urlizeString(address.value)}&key=AIzaSyA7FZ14h7xhNNN5QmXt5lJpzPArNjvNfOQ`, function success(response){
    })
    .then(data => {
            var locatedAt = data.results[0].geometry.location;
            var map = new google.maps.Map(document.getElementById('map'), {
                center: {lat: locatedAt.lat, lng: locatedAt.lng},
                zoom: 15,
                gestureHandling: 'cooperative',
                zoomControl: false,
                scrollwheel: false
            });

                var marker = new google.maps.Marker({
                    map: map,
                    anchorPoint: new google.maps.Point(0, -29),
                    icon: {
                        path: google.maps.SymbolPath.CIRCLE,
                        scale: 90.5,
                        fillColor: "#481d5a",
                        fillOpacity: 0.3,
                        strokeWeight: 0.4
                    }
            });
            marker.setPosition(locatedAt);
            //marker.setVisible(true);
        });
};

urlizeString = function(string){
    return string.replace(" ","+");
};

getDistanceAndTime = function(){
    var destination = document.getElementById('address');
    var origin = document.getElementById('current_user_address');
    $.getJSON(`https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${urlizeString(origin.value)}&destinations=${urlizeString(destination.value)}&key=AIzaSyA7FZ14h7xhNNN5QmXt5lJpzPArNjvNfOQ`, function success(response){
    })
    .then(data => {
        var time = data.rows[0].elements[0].duration.text;
        var distance = data.rows[0].elements[0].distance.text;
        document.getElementById('time').innerHTML = "Tiempo de llegada: " + time;
        document.getElementById('distance').innerHTML = "Distancia: " + distance;
    });
};

setDataInTable = function(cell){
    var data = cell.dataset;
    var point_a = { lat: parseFloat(data.originLat), lng: parseFloat(data.originLon)};
    var point_b = { lat: parseFloat(data.destLat), lng: parseFloat(data.destLon)}
    var service = new google.maps.DistanceMatrixService;
    service.getDistanceMatrix({
        origins: [point_a],
        destinations: [point_b],
        travelMode: 'WALKING',
    }, function(response, status){
        duration = response.rows[0].elements[0].duration.text;
        cell.innerText = "Aprox. " + duration.toString();
    })
};

showDistanceWalking = function(){
    row = document.getElementsByClassName('distance-data-js');
    Array.from(row).forEach(setDataInTable);
};

createMarker = function(map, lat, lng) {
    var pos = {};
    pos["lat"] = lat;
    pos["lng"] = lng;
    var marker = new google.maps.Marker({position: pos, map: map, icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 10,
            fillColor: "#481d5a",
            fillOpacity: 0.3,
            strokeWeight: 0.4
        }});
    return marker;
};

booksNearYourZone = function(){
    var address = document.getElementById('address');
    $.getJSON(`https://maps.googleapis.com/maps/api/geocode/json?address=${urlizeString(address.value)}&key=AIzaSyA7FZ14h7xhNNN5QmXt5lJpzPArNjvNfOQ`, function success(response){
    })
        .then(data => {
        var locatedAt = data.results[0].geometry.location;
        console.log(locatedAt);
    var map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: locatedAt.lat, lng: locatedAt.lng},
        maxZoom: 12,
        gestureHandling: 'none',
        zoomControl: false,
        scrollwheel: false
    });

    var marker = new google.maps.Marker({
        map: map,
        anchorPoint: new google.maps.Point(0, -29),
        icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 10,
            fillColor: "#481d5a",
            fillOpacity: 0.3,
            strokeWeight: 0.4
        }
    });
    marker.setPosition(locatedAt);
    //marker.setVisible(true);
    //var pos = { lat: -34.6035518​, lng: -58.382388};
    var pos = {};
    pos["lat"] = -34.7755;
    pos["lng"] = -58.2583;
    var pos2 = {};
    pos2["lat"] = -33.7755;
    pos2["lng"] = -57.2583;
    var marker2 = new google.maps.Marker({position: pos, map: map, icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 10,
            fillColor: "#481d5a",
            fillOpacity: 0.3,
            strokeWeight: 0.4
        }});
    // var marker3 = new google.maps.Marker({position: pos2, map: map, icon: {
    //         path: google.maps.SymbolPath.CIRCLE,
    //         scale: 10,
    //         fillColor: "#481d5a",
    //         fillOpacity: 0.3,
    //         strokeWeight: 0.4
    //     }});
    var marker3 = createMarker(map, -33.7755, -50.2583);
    //marker2.setPosition();
    var markers = [marker, marker2, marker3];//some array
    var bounds = new google.maps.LatLngBounds();
    for (var i = 0; i < markers.length; i++) {
        bounds.extend(markers[i].getPosition());
    }
    map.fitBounds(bounds);
    console.log(map.getZoom())
    if (map.getZoom() > 9){
        console.log(map.getZoom())
        map.setZoom(9);
    }
    });
    };


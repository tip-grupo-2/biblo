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
            marker.setVisible(true);
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
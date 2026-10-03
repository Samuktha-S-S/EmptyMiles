<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Location"/>
    <jsp:param name="nav" value="location"/>
</jsp:include>

<div class="page-head">
    <div>
        <h1>Location &amp; route</h1>
        <p>Matching uses where your vehicle is now and where it's already heading. Keep both up to date.</p>
    </div>
</div>

<c:if test="${empty vehicles}">
    <section class="card">
        <div class="empty">
            <div class="empty-icon"><svg class="i"><use href="${ico}#crosshair"/></svg></div>
            <h3>No vehicle to locate</h3>
            <p>Add a vehicle first, then share its location here.</p>
            <a class="btn btn-primary" href="${ctx}/partner/vehicles#add"><svg class="i"><use href="${ico}#plus"/></svg><span>Add vehicle</span></a>
        </div>
    </section>
</c:if>

<c:forEach var="v" items="${vehicles}">
    <c:set var="vt" value="${fn:toLowerCase(v.vehicleType)}"/>
    <section class="card" style="margin-bottom:20px">
        <div class="card-head">
            <span class="vtype-icon" style="width:40px;height:40px"><svg class="i" style="width:22px;height:22px"><use href="${ico}#${vt}"/></svg></span>
            <div>
                <h2 style="text-transform:capitalize">${vt}</h2>
                <span class="reg-plate"><c:out value="${v.vehicleNumber}"/></span>
            </div>
            <span class="badge vstatus-${v.status} push-right">${v.status == 'AVAILABLE' ? 'Available' : (v.status == 'BUSY' ? 'Full' : 'Offline')}</span>
        </div>
        <div class="grid-2" style="align-items:start">
            <div>
                <form method="post" action="${ctx}/partner/location" class="validate fieldset" novalidate>
                    <div class="fieldset-title"><svg class="i"><use href="${ico}#crosshair"/></svg>Current location</div>
                    <input type="hidden" name="action" value="location">
                    <input type="hidden" name="vehicleId" value="${v.id}">
                    <div class="form-row">
                        <label class="field"><span>Latitude</span><input type="number" step="any" min="-90" max="90" name="latitude" id="lat${v.id}" value="${v.currentLatitude}" required></label>
                        <label class="field"><span>Longitude</span><input type="number" step="any" min="-180" max="180" name="longitude" id="lng${v.id}" value="${v.currentLongitude}" required></label>
                    </div>
                    <div class="button-row" style="margin-bottom:16px">
                        <button type="button" class="btn btn-outline btn-sm" data-geolocate="lat${v.id},lng${v.id}"><svg class="i"><use href="${ico}#crosshair"/></svg><span>Use my current location</span></button>
                        <button type="submit" class="btn btn-primary btn-sm push-right"><span>Save location</span></button>
                    </div>
                </form>

                <form method="post" action="${ctx}/partner/location" class="validate fieldset" novalidate>
                    <div class="fieldset-title"><svg class="i"><use href="${ico}#flag"/></svg>Where are you heading? <span class="hint" style="font-weight:400">optional, helps route matching</span></div>
                    <input type="hidden" name="action" value="route">
                    <input type="hidden" name="vehicleId" value="${v.id}">
                    <label class="field"><span>Destination</span>
                        <input type="text" name="destination" id="dest${v.id}" value="<c:out value='${v.destination}'/>" placeholder="Leave empty if you have no fixed route">
                    </label>
                    <div class="form-row">
                        <label class="field"><span>Latitude</span><input type="number" step="any" min="-90" max="90" name="destinationLatitude" id="dlat${v.id}" value="${v.destinationLatitude}"></label>
                        <label class="field"><span>Longitude</span><input type="number" step="any" min="-180" max="180" name="destinationLongitude" id="dlng${v.id}" value="${v.destinationLongitude}"></label>
                    </div>
                    <div class="button-row" style="margin-bottom:16px">
                        <button type="button" class="btn btn-outline btn-sm" data-lookup="dest${v.id},dlat${v.id},dlng${v.id}"><svg class="i"><use href="${ico}#search"/></svg><span>Look up address</span></button>
                        <button type="submit" class="btn btn-primary btn-sm push-right"><span>Save route</span></button>
                    </div>
                </form>
            </div>
            <div>
                <div class="route-map" data-route-map style="height:300px"
                     data-vehicle="${v.hasLocation() ? v.currentLatitude.toString().concat(',').concat(v.currentLongitude) : ''}"
                     data-vehicle-label="You are here" data-vehicle-legend="Your vehicle"
                     data-dest="${v.hasDestination() ? v.destinationLatitude.toString().concat(',').concat(v.destinationLongitude) : ''}"
                     data-dest-label="<c:out value='${v.destination}'/>"
                     data-empty-text="Location not shared yet. Use your current location or type the coordinates."></div>
                <p class="small subtle" style="margin-top:8px">During a delivery, your location is also shared automatically from the delivery page.</p>
            </div>
        </div>
    </section>
</c:forEach>

<script src="${ctx}/assets/js/route-map.js"></script>
<script src="${ctx}/assets/js/geolocation.js"></script>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>

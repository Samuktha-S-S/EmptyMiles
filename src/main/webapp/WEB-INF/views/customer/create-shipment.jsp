<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Send Goods"/>
    <jsp:param name="nav" value="send"/>
</jsp:include>

<c:choose>
<%-- ===== Saved: shipment created by the backend ===== --%>
<c:when test="${not empty createdShipment}">
    <c:set var="s" value="${createdShipment}"/>
    <div class="card" style="max-width:640px;margin:16px auto 0">
        <div class="success-hero">
            <div class="check"><svg class="i"><use href="${ico}#check"/></svg></div>
            <h2>Shipment created</h2>
            <p>Shipment #${s.id} is saved. Next, find a vehicle with free space on your route.</p>
        </div>
        <div class="summary-list" style="margin-bottom:20px">
            <div><span class="k">Package</span><span class="v"><c:out value="${s.productName}"/> &times; ${s.quantity}, <fmt:formatNumber value="${s.weight}" maxFractionDigits="2"/> kg</span></div>
            <div><span class="k">Route</span><span class="v"><c:out value="${s.pickupAddress}"/> &rarr; <c:out value="${s.destinationAddress}"/></span></div>
            <c:if test="${not empty s.pickupDate}">
                <div><span class="k">Pickup</span><span class="v">${s.pickupDate.format(df)}<c:if test="${not empty s.pickupTimeSlot}">, <c:out value="${s.pickupTimeSlot}"/></c:if></span></div>
            </c:if>
        </div>
        <div class="button-row">
            <a class="btn btn-outline" href="${ctx}/customer/dashboard"><span>Back to dashboard</span></a>
            <a class="btn btn-primary btn-lg push-right" data-loading href="${ctx}/customer/matches?shipmentId=${s.id}"><span>Continue to Find Vehicles</span><svg class="i"><use href="${ico}#arrow-right"/></svg></a>
        </div>
    </div>
</c:when>

<%-- ===== Step-by-step form ===== --%>
<c:otherwise>
<div class="page-head">
    <div>
        <h1>Send Goods</h1>
        <p>Tell us what you're sending and where. We'll match it with vehicles already heading that way.</p>
    </div>
</div>

<form method="post" action="${ctx}/customer/shipment/new" id="shipmentForm" class="validate" novalidate
      data-start-step="${empty error ? 1 : 4}">

    <div class="stepper" role="list">
        <button type="button" class="step" data-step-tab="1" role="listitem"><span class="step-num"><span>1</span><svg class="i"><use href="${ico}#check"/></svg></span><span class="step-text"><small>Step 1</small><b>Package</b></span></button>
        <button type="button" class="step" data-step-tab="2" role="listitem"><span class="step-num"><span>2</span><svg class="i"><use href="${ico}#check"/></svg></span><span class="step-text"><small>Step 2</small><b>Route</b></span></button>
        <button type="button" class="step" data-step-tab="3" role="listitem"><span class="step-num"><span>3</span><svg class="i"><use href="${ico}#check"/></svg></span><span class="step-text"><small>Step 3</small><b>Schedule</b></span></button>
        <button type="button" class="step" data-step-tab="4" role="listitem"><span class="step-num"><span>4</span><svg class="i"><use href="${ico}#check"/></svg></span><span class="step-text"><small>Step 4</small><b>Review</b></span></button>
    </div>

    <div class="card">
        <%-- STEP 1: PACKAGE --%>
        <section class="wizard-panel" data-step="1">
            <div class="card-head"><h2>Package details</h2><span class="sub">What are you sending?</span></div>
            <div class="form-row">
                <label class="field"><span>Product name</span>
                    <input type="text" name="productName" value="<c:out value='${param.productName}'/>" placeholder="e.g. Cardboard box of clothes" maxlength="100" required>
                </label>
                <label class="field"><span>Product type</span>
                    <select name="productType" required>
                        <c:forEach var="t" items="${['Clothes','Documents','Electronics','Food','Groceries','Furniture','Medicines','Other']}">
                            <option ${param.productType == t ? 'selected' : ''}>${t}</option>
                        </c:forEach>
                    </select>
                </label>
            </div>
            <div class="form-row">
                <label class="field"><span>Quantity <span class="hint">items</span></span>
                    <input type="number" name="quantity" min="1" step="1" value="${empty param.quantity ? 1 : param.quantity}" required>
                </label>
                <label class="field"><span>Total weight</span>
                    <span class="input-group"><input type="number" name="weight" min="0.1" step="0.1" value="<c:out value='${param.weight}'/>" placeholder="5" required><span class="unit">kg</span></span>
                </label>
            </div>

            <div class="fieldset">
                <div class="fieldset-title"><svg class="i"><use href="${ico}#ruler"/></svg>Dimensions <span class="hint" style="font-weight:400">optional, per item</span></div>
                <div class="form-row-3">
                    <label class="field"><span>Length</span>
                        <span class="input-group"><input type="number" name="lengthCm" min="0.1" step="0.1" value="<c:out value='${param.lengthCm}'/>"><span class="unit">cm</span></span>
                    </label>
                    <label class="field"><span>Width</span>
                        <span class="input-group"><input type="number" name="widthCm" min="0.1" step="0.1" value="<c:out value='${param.widthCm}'/>"><span class="unit">cm</span></span>
                    </label>
                    <label class="field"><span>Height</span>
                        <span class="input-group"><input type="number" name="heightCm" min="0.1" step="0.1" value="<c:out value='${param.heightCm}'/>"><span class="unit">cm</span></span>
                    </label>
                </div>
            </div>

            <label class="field"><span>Special requirements <span class="optional">(optional)</span></span>
                <input type="text" name="specialRequirements" id="specialRequirements" maxlength="255" value="<c:out value='${param.specialRequirements}'/>" placeholder="e.g. Fragile, keep upright">
            </label>
            <div class="chips" style="margin:-6px 0 8px" data-append-to="specialRequirements">
                <button type="button" class="chip">Fragile</button>
                <button type="button" class="chip">Keep upright</button>
                <button type="button" class="chip">Keep dry</button>
                <button type="button" class="chip">Perishable</button>
            </div>
        </section>

        <%-- STEP 2: ROUTE --%>
        <section class="wizard-panel" data-step="2">
            <div class="card-head"><h2>Route</h2><span class="sub">Where should we pick up and deliver?</span></div>
            <div class="grid-2" style="align-items:start">
                <div>
                    <div class="fieldset">
                        <div class="fieldset-title"><svg class="i"><use href="${ico}#pin"/></svg>Pickup location</div>
                        <label class="field"><span>Address</span>
                            <input type="text" name="pickupAddress" id="pickupAddress" value="<c:out value='${param.pickupAddress}'/>" placeholder="e.g. T. Nagar, Chennai" maxlength="255" required>
                        </label>
                        <div class="form-row">
                            <label class="field"><span>Latitude</span><input type="number" step="any" min="-90" max="90" name="pickupLatitude" id="pickupLatitude" value="<c:out value='${param.pickupLatitude}'/>" required></label>
                            <label class="field"><span>Longitude</span><input type="number" step="any" min="-180" max="180" name="pickupLongitude" id="pickupLongitude" value="<c:out value='${param.pickupLongitude}'/>" required></label>
                        </div>
                        <div class="button-row" style="margin:-4px 0 16px">
                            <button type="button" class="btn btn-sm btn-outline" data-geolocate="pickupLatitude,pickupLongitude"><svg class="i"><use href="${ico}#crosshair"/></svg>Use my location</button>
                            <button type="button" class="btn btn-sm btn-outline" data-lookup="pickupAddress,pickupLatitude,pickupLongitude"><svg class="i"><use href="${ico}#search"/></svg>Look up address</button>
                        </div>
                    </div>
                    <div class="fieldset">
                        <div class="fieldset-title"><svg class="i"><use href="${ico}#flag"/></svg>Delivery location</div>
                        <label class="field"><span>Address</span>
                            <input type="text" name="destinationAddress" id="destinationAddress" value="<c:out value='${param.destinationAddress}'/>" placeholder="e.g. Adyar, Chennai" maxlength="255" required>
                        </label>
                        <div class="form-row">
                            <label class="field"><span>Latitude</span><input type="number" step="any" min="-90" max="90" name="destinationLatitude" id="destinationLatitude" value="<c:out value='${param.destinationLatitude}'/>" required></label>
                            <label class="field"><span>Longitude</span><input type="number" step="any" min="-180" max="180" name="destinationLongitude" id="destinationLongitude" value="<c:out value='${param.destinationLongitude}'/>" required></label>
                        </div>
                        <div class="button-row" style="margin:-4px 0 16px">
                            <button type="button" class="btn btn-sm btn-outline" data-lookup="destinationAddress,destinationLatitude,destinationLongitude"><svg class="i"><use href="${ico}#search"/></svg>Look up address</button>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="route-map" id="routePreview" data-route-map style="height:340px"
                         data-empty-text="Enter pickup and delivery coordinates (or use Look up address) to preview the route."></div>
                    <p class="small subtle" style="margin-top:8px">Address search uses free OpenStreetMap data. You can also type coordinates yourself.</p>
                </div>
            </div>
        </section>

        <%-- STEP 3: SCHEDULE --%>
        <section class="wizard-panel" data-step="3">
            <div class="card-head"><h2>Schedule</h2><span class="sub">When should the partner pick it up?</span></div>
            <div class="form-row">
                <label class="field"><span>Pickup date <span class="optional">(optional)</span></span>
                    <input type="date" name="pickupDate" id="pickupDate" value="<c:out value='${param.pickupDate}'/>">
                </label>
                <div class="field"><span class="field-label">Preferred pickup time <span class="optional">(optional)</span></span>
                    <div class="chips">
                        <c:forEach var="slot" items="${['Morning','Afternoon','Evening','Anytime']}">
                            <label class="chip-radio"><input type="radio" name="pickupTimeSlot" value="${slot}" ${param.pickupTimeSlot == slot ? 'checked' : ''}><span class="chip">${slot}</span></label>
                        </c:forEach>
                    </div>
                    <span class="hint">Morning 8&ndash;12 &middot; Afternoon 12&ndash;4 &middot; Evening 4&ndash;8</span>
                </div>
            </div>
            <label class="field"><span>Special instructions <span class="optional">(optional)</span></span>
                <textarea name="specialInstructions" maxlength="500" placeholder="e.g. Call before arriving. Gate code 1234."><c:out value="${param.specialInstructions}"/></textarea>
            </label>
        </section>

        <%-- STEP 4: REVIEW (filled by shipment-wizard.js from the fields above) --%>
        <section class="wizard-panel" data-step="4">
            <div class="card-head"><h2>Review your shipment</h2><span class="sub">Check the details before confirming.</span></div>
            <div class="review-grid">
                <div class="review-block">
                    <div class="section-label"><svg class="i i-sm"><use href="${ico}#package"/></svg>Package<button type="button" data-goto="1">Edit</button></div>
                    <div class="big" data-review="package"></div>
                    <div class="muted" data-review="packageMeta"></div>
                </div>
                <div class="review-block">
                    <div class="section-label"><svg class="i i-sm"><use href="${ico}#calendar"/></svg>Date<button type="button" data-goto="3">Edit</button></div>
                    <div class="big" data-review="date"></div>
                    <div class="muted" data-review="instructions"></div>
                </div>
                <div class="review-block" style="grid-column:1/-1">
                    <div class="section-label"><svg class="i i-sm"><use href="${ico}#route"/></svg>Route<button type="button" data-goto="2">Edit</button></div>
                    <div class="grid-2" style="align-items:center">
                        <div class="route">
                            <div class="route-stop"><span class="route-dot"></span><div><div class="k">Pickup</div><div class="v" data-review="pickup"></div></div></div>
                            <div class="route-stop to"><span class="route-dot"></span><div><div class="k">Destination</div><div class="v" data-review="destination"></div></div></div>
                        </div>
                        <div class="route-map" id="routeReview" data-route-map style="height:200px;min-height:200px"></div>
                    </div>
                </div>
            </div>
        </section>

        <div class="wizard-foot">
            <button type="button" class="btn btn-outline" data-prev><svg class="i"><use href="${ico}#arrow-left"/></svg><span>Back</span></button>
            <span class="small subtle" data-step-hint></span>
            <button type="button" class="btn btn-primary push-right" data-next><span>Continue</span><svg class="i"><use href="${ico}#arrow-right"/></svg></button>
            <button type="submit" class="btn btn-primary btn-lg push-right" data-submit hidden><svg class="i"><use href="${ico}#check"/></svg><span>Confirm Shipment</span></button>
        </div>
    </div>
</form>

<script src="${ctx}/assets/js/route-map.js"></script>
<script src="${ctx}/assets/js/geolocation.js"></script>
<script src="${ctx}/assets/js/shipment-wizard.js"></script>
</c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>

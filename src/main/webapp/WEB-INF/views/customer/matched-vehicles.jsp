<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Find Vehicles"/>
    <jsp:param name="nav" value="find"/>
</jsp:include>
<%-- Every number on this page comes from the matching engine (MatchResult) or the shipment. --%>

<a class="back-link" href="${ctx}/customer/find-vehicles"><svg class="i i-sm"><use href="${ico}#arrow-left"/></svg>All shipments</a>
<div class="page-head">
    <div>
        <h1>Matching vehicles</h1>
        <p>Vehicles with enough free space, near your pickup and on a compatible route.</p>
    </div>
    <div class="actions">
        <a class="btn btn-outline" data-loading href="${ctx}/customer/matches?shipmentId=${shipment.id}"><svg class="i"><use href="${ico}#refresh"/></svg><span>Search again</span></a>
    </div>
</div>

<div class="shipment-strip">
    <span class="pk"><svg class="i i-lg"><use href="${ico}#package"/></svg></span>
    <div>
        <div class="title"><c:out value="${shipment.productName}"/> &times; ${shipment.quantity}</div>
        <div class="meta">Shipment #${shipment.id} &middot; <c:out value="${shipment.productType}"/>
            <c:if test="${not empty shipment.pickupDate}"> &middot; Pickup ${shipment.pickupDate.format(df)}</c:if></div>
    </div>
    <div class="route">
        <div class="route-stop"><span class="route-dot"></span><div><div class="k">Pickup</div><div class="v"><c:out value="${shipment.pickupAddress}"/></div></div></div>
        <div class="route-stop to"><span class="route-dot"></span><div><div class="k">Destination</div><div class="v"><c:out value="${shipment.destinationAddress}"/></div></div></div>
    </div>
    <div class="weight-pill"><fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg<small>to send</small></div>
</div>

<c:choose>
<%-- ===== No match ===== --%>
<c:when test="${empty matches}">
    <section class="card">
        <div class="empty">
            <div class="empty-icon warn"><svg class="i"><use href="${ico}#truck"/></svg></div>
            <h2>No suitable vehicle right now</h2>
            <p>We couldn't find a vehicle with enough available capacity on a compatible route.</p>
            <div style="margin-top:8px">
                <div class="section-label" style="text-align:left">Possible reasons</div>
                <ul class="reasons">
                    <li>No nearby vehicle</li>
                    <li>Insufficient available capacity</li>
                    <li>No compatible route</li>
                    <li>Vehicle currently unavailable</li>
                </ul>
            </div>
            <div class="button-row" style="justify-content:center;margin-top:8px">
                <a class="btn btn-outline" href="${ctx}/customer/dashboard"><span>Back to dashboard</span></a>
                <a class="btn btn-primary" data-loading href="${ctx}/customer/matches?shipmentId=${shipment.id}"><svg class="i"><use href="${ico}#refresh"/></svg><span>Search Again</span></a>
            </div>
        </div>
    </section>
</c:when>

<%-- ===== Vehicle cards ===== --%>
<c:otherwise>
    <div class="results-bar">
        <h2>${fn:length(matches)} ${fn:length(matches) == 1 ? 'vehicle matches' : 'vehicles match'}</h2>
        <c:if test="${fn:length(matches) > 1}">
            <div class="push-right" data-sort-for="matchList">
                <span class="small subtle">Sort by</span>
                <div class="chips">
                    <button type="button" class="chip" data-sort="score" data-dir="desc" aria-pressed="true">Best Match</button>
                    <button type="button" class="chip" data-sort="distance" data-dir="asc" aria-pressed="false">Distance</button>
                    <button type="button" class="chip" data-sort="capacity" data-dir="desc" aria-pressed="false">Available Capacity</button>
                </div>
            </div>
        </c:if>
    </div>

    <div class="match-list" id="matchList">
    <c:forEach var="m" items="${matches}" varStatus="loop">
        <c:set var="v" value="${m.vehicle}"/>
        <c:set var="vt" value="${fn:toLowerCase(v.vehicleType)}"/>
        <article class="vcard ${loop.first ? 'is-best' : ''}"
                 data-score="${m.matchScore}" data-distance="${m.distanceToPickupKm}" data-capacity="${v.availableCapacity}">
            <div class="vcard-main">
                <div class="vcard-head">
                    <span class="vtype-icon"><svg class="i"><use href="${ico}#${vt}"/></svg></span>
                    <div>
                        <h3>${vt}</h3>
                        <span class="reg-plate"><c:out value="${v.vehicleNumber}"/></span>
                    </div>
                    <div class="push-right row-flex">
                        <c:if test="${loop.first}"><span class="best-tag"><svg class="i"><use href="${ico}#star"/></svg>Best match</span></c:if>
                    </div>
                </div>

                <div class="facts">
                    <div class="fact">
                        <div class="k"><svg class="i"><use href="${ico}#gauge"/></svg>Available capacity</div>
                        <div class="v"><fmt:formatNumber value="${v.availableCapacity}" maxFractionDigits="2"/> kg <small>of <fmt:formatNumber value="${v.totalCapacity}" maxFractionDigits="2"/></small></div>
                    </div>
                    <div class="fact">
                        <div class="k"><svg class="i"><use href="${ico}#weight"/></svg>Shipment weight</div>
                        <div class="v"><fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg</div>
                    </div>
                    <div class="fact">
                        <div class="k"><svg class="i"><use href="${ico}#nav"/></svg>Distance to pickup</div>
                        <div class="v"><fmt:formatNumber value="${m.distanceToPickupKm}" maxFractionDigits="1"/> km</div>
                    </div>
                    <div class="fact">
                        <div class="k"><svg class="i"><use href="${ico}#route"/></svg>Route</div>
                        <div class="v ok">Compatible &#10003;</div>
                    </div>
                    <div class="fact">
                        <div class="k"><svg class="i"><use href="${ico}#power"/></svg>Availability</div>
                        <div class="v ok">${v.status == 'AVAILABLE' ? 'Available' : v.status} &#10003;</div>
                    </div>
                    <div class="fact">
                        <div class="k"><svg class="i"><use href="${ico}#flag"/></svg>Trip distance</div>
                        <div class="v"><fmt:formatNumber value="${m.tripDistanceKm}" maxFractionDigits="1"/> km</div>
                    </div>
                </div>

                <c:if test="${v.totalCapacity > 0}">
                    <div class="capacity-viz">
                        <div class="bar">
                            <span class="used" style="width:${v.currentLoad * 100 / v.totalCapacity}%"></span>
                            <span class="this" style="width:${shipment.weight * 100 / v.totalCapacity}%"></span>
                        </div>
                        <div class="legend">
                            <span><i style="background:#b8c4d6"></i>Already loaded <fmt:formatNumber value="${v.currentLoad}" maxFractionDigits="2"/> kg</span>
                            <span><i style="background:var(--teal-600)"></i>Your goods <fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg</span>
                            <span><i style="background:#edf1f6;border:1px solid var(--border)"></i>Still free after <fmt:formatNumber value="${v.availableCapacity - shipment.weight}" maxFractionDigits="2"/> kg</span>
                        </div>
                    </div>
                </c:if>
                <div class="vcard-why">
                    <div class="section-label">Why this vehicle matches</div>
                    <ul class="why">
                        <li><svg class="i"><use href="${ico}#check"/></svg><div>Enough available capacity
                            <small><fmt:formatNumber value="${v.availableCapacity}" maxFractionDigits="2"/> kg free for your <fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg</small></div></li>
                        <li><svg class="i"><use href="${ico}#check"/></svg><div>Pickup location is nearby
                            <small><fmt:formatNumber value="${m.distanceToPickupKm}" maxFractionDigits="1"/> km away, within its <fmt:formatNumber value="${v.vehicleType.maxPickupRadiusKm}" maxFractionDigits="0"/> km range</small></div></li>
                        <li><svg class="i"><use href="${ico}#check"/></svg><div>Route is compatible
                            <small>
                                <c:choose>
                                    <c:when test="${m.onRoute}">Already heading to <c:out value="${v.destination}"/>, <fmt:formatNumber value="${m.detourKm}" maxFractionDigits="1"/> km extra</c:when>
                                    <c:otherwise>No fixed route, can go straight to your pickup</c:otherwise>
                                </c:choose>
                            </small></div></li>
                        <li><svg class="i"><use href="${ico}#check"/></svg><div>Vehicle is available<small>The partner is taking bookings now</small></div></li>
                    </ul>
                </div>
            </div>

            <aside class="vcard-side">
                <div class="score">
                    <div class="score-ring" style="--p:${m.matchScore}"><span><fmt:formatNumber value="${m.matchScore}" maxFractionDigits="0"/></span></div>
                    <div>
                        <div class="k">Match score</div>
                        <div class="v"><fmt:formatNumber value="${m.matchScore}" minFractionDigits="1" maxFractionDigits="1"/> / 100</div>
                    </div>
                </div>
                <div class="partner-line">
                    <span class="avatar"><c:out value="${fn:substring(v.partnerName, 0, 1)}"/></span>
                    <div><div class="small subtle">Travel partner</div><div style="font-weight:600"><c:out value="${v.partnerName}"/></div></div>
                </div>
                <div class="price-line">
                    <span class="k">Estimated cost</span>
                    <span class="v">&#8377;<fmt:formatNumber value="${m.estimatedCost}" pattern="#,##0"/></span>
                </div>
                <form method="post" action="${ctx}/customer/book" id="book-${v.id}">
                    <input type="hidden" name="shipmentId" value="${shipment.id}">
                    <input type="hidden" name="vehicleId" value="${v.id}">
                </form>
                <button type="button" class="btn btn-primary btn-block" data-book="book-${v.id}"
                        data-vehicle="${vt}" data-number="<c:out value='${v.vehicleNumber}'/>"
                        data-partner="<c:out value='${v.partnerName}'/>"
                        data-capacity="<fmt:formatNumber value='${v.availableCapacity}' maxFractionDigits='2'/> kg"
                        data-cost="&#8377;<fmt:formatNumber value='${m.estimatedCost}' pattern='#,##0'/>"
                        data-score="<fmt:formatNumber value='${m.matchScore}' minFractionDigits='1' maxFractionDigits='1'/> / 100">
                    <span>Request Booking</span>
                </button>
            </aside>
        </article>
    </c:forEach>
    </div>

    <%-- Confirmation before the booking is sent to the partner --%>
    <div class="modal" id="bookModal" role="dialog" aria-modal="true" aria-labelledby="bookTitle">
        <div class="modal-card">
            <div class="modal-head">
                <div>
                    <div class="eyebrow">Confirm booking</div>
                    <h2 id="bookTitle">Send this request to the partner?</h2>
                    <p>The partner accepts or declines. You'll get a delivery OTP once they accept.</p>
                </div>
                <button type="button" class="modal-close" data-modal-close aria-label="Close"><svg class="i"><use href="${ico}#x"/></svg></button>
            </div>
            <div class="modal-body">
                <dl class="summary-list" style="margin:0">
                    <div><dt>Shipment</dt><dd><c:out value="${shipment.productName}"/></dd></div>
                    <div><dt>Weight</dt><dd><fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg</dd></div>
                    <div><dt>Vehicle</dt><dd data-fill="vehicle"></dd></div>
                    <div><dt>Partner</dt><dd data-fill="partner"></dd></div>
                    <div><dt>Available capacity</dt><dd data-fill="capacity"></dd></div>
                    <div><dt>Pickup</dt><dd><c:out value="${shipment.pickupAddress}"/></dd></div>
                    <div><dt>Destination</dt><dd><c:out value="${shipment.destinationAddress}"/></dd></div>
                    <div><dt>Match score</dt><dd data-fill="score"></dd></div>
                    <div><dt>Estimated cost</dt><dd data-fill="cost"></dd></div>
                </dl>
            </div>
            <div class="modal-foot">
                <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary" id="bookConfirm" data-autofocus><span>Confirm Booking</span></button>
            </div>
        </div>
    </div>
    <script>
        // Fill the modal from the chosen card and point its Confirm button at that card's form
        document.querySelectorAll('[data-book]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                const modal = document.getElementById('bookModal');
                const d = btn.dataset;
                modal.querySelector('[data-fill=vehicle]').textContent = d.vehicle.charAt(0).toUpperCase() + d.vehicle.slice(1) + ' · ' + d.number;
                modal.querySelector('[data-fill=partner]').textContent = d.partner;
                modal.querySelector('[data-fill=capacity]').textContent = d.capacity;
                modal.querySelector('[data-fill=score]').textContent = d.score;
                modal.querySelector('[data-fill=cost]').textContent = d.cost;
                document.getElementById('bookConfirm').setAttribute('form', d.book);
                window.EM.openModal(modal);
            });
        });
    </script>
</c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>

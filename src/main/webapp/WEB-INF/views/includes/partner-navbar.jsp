<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Travel partner sidebar links. param.nav (passed to header.jsp) names the active item. --%>
<c:set var="ico" value="${pageContext.request.contextPath}/assets/images/icons.svg"/>
<div class="nav-label">Menu</div>
<nav class="nav">
    <a href="${pageContext.request.contextPath}/partner/dashboard" class="${param.nav == 'dashboard' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#grid"/></svg>Dashboard</a>
    <a href="${pageContext.request.contextPath}/partner/vehicles" class="${param.nav == 'vehicles' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#truck"/></svg>My Vehicle</a>
    <a href="${pageContext.request.contextPath}/partner/matching-shipments" class="${param.nav == 'matching' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#search"/></svg>Matching Shipments</a>
    <a href="${pageContext.request.contextPath}/partner/requests" class="${param.nav == 'requests' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#inbox"/></svg>Booking Requests</a>
    <a href="${pageContext.request.contextPath}/partner/delivery" class="${param.nav == 'delivery' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#route"/></svg>Active Deliveries</a>
    <a href="${pageContext.request.contextPath}/partner/location" class="${param.nav == 'location' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#crosshair"/></svg>Location</a>
    <a href="${pageContext.request.contextPath}/partner/profile" class="${param.nav == 'profile' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#user"/></svg>Profile</a>
</nav>

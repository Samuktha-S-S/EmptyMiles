<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Customer sidebar links. param.nav (passed to header.jsp) names the active item. --%>
<c:set var="ico" value="${pageContext.request.contextPath}/assets/images/icons.svg"/>
<div class="nav-label">Menu</div>
<nav class="nav">
    <a href="${pageContext.request.contextPath}/customer/dashboard" class="${param.nav == 'dashboard' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#grid"/></svg>Dashboard</a>
    <a href="${pageContext.request.contextPath}/customer/shipment/new" class="${param.nav == 'send' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#package"/></svg>Send Goods</a>
    <a href="${pageContext.request.contextPath}/customer/shipments" class="${param.nav == 'shipments' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#boxes"/></svg>My Shipments</a>
    <a href="${pageContext.request.contextPath}/customer/find-vehicles" class="${param.nav == 'find' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#truck"/></svg>Find Vehicles</a>
    <a href="${pageContext.request.contextPath}/customer/track" class="${param.nav == 'track' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#pin"/></svg>Track Delivery</a>
    <a href="${pageContext.request.contextPath}/customer/profile" class="${param.nav == 'profile' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#user"/></svg>Profile</a>
</nav>

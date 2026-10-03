<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter, java.util.Locale" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Shared page top. Include with:
       <jsp:include page="/WEB-INF/views/includes/header.jsp">
           <jsp:param name="title" value="..."/>
           <jsp:param name="nav" value="dashboard"/>   (sidebar item to highlight)
       </jsp:include>
     Sets request attributes ctx (context path), ico (icon sprite) and date formats dtf/df/tf for the page. --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<c:set var="ico" value="${pageContext.request.contextPath}/assets/images/icons.svg" scope="request"/>
<%-- Date formats for LocalDate/LocalDateTime values: ${x.format(dtf)} --%>
<c:set var="dtf" value="${DateTimeFormatter.ofPattern('dd MMM yyyy, hh:mm a', Locale.ENGLISH)}" scope="request"/>
<c:set var="df" value="${DateTimeFormatter.ofPattern('dd MMM yyyy', Locale.ENGLISH)}" scope="request"/>
<c:set var="tf" value="${DateTimeFormatter.ofPattern('hh:mm a', Locale.ENGLISH)}" scope="request"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${param.title}"/> | EmptyMiles</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/dashboard.css">
    <script>window.APP_CONTEXT = '${ctx}';</script>
</head>
<body>
<c:choose>
<c:when test="${not empty sessionScope.user}">
<div class="app" id="app">
    <aside class="sidebar" id="sidebar" aria-label="Main navigation">
        <a class="brand" href="${ctx}/${sessionScope.user.role == 'PARTNER' ? 'partner' : 'customer'}/dashboard">
            <span class="brand-mark"><svg class="i"><use href="${ico}#route"/></svg></span>
            <span>EMPTY<b>MILES</b></span>
        </a>
        <c:choose>
            <c:when test="${sessionScope.user.role == 'PARTNER'}">
                <jsp:include page="/WEB-INF/views/includes/partner-navbar.jsp"/>
            </c:when>
            <c:otherwise>
                <jsp:include page="/WEB-INF/views/includes/customer-navbar.jsp"/>
            </c:otherwise>
        </c:choose>
        <div class="sidebar-bottom">
            <nav class="nav">
                <a href="${ctx}/help" class="${param.nav == 'help' ? 'is-active' : ''}"><svg class="i"><use href="${ico}#help"/></svg>Help</a>
                <a href="${ctx}/logout"><svg class="i"><use href="${ico}#logout"/></svg>Logout</a>
            </nav>
            <div class="sidebar-user">
                <span class="avatar"><c:out value="${sessionScope.user.name.substring(0, 1)}"/></span>
                <div>
                    <div class="name"><c:out value="${sessionScope.user.name}"/></div>
                    <div class="role">${sessionScope.user.role == 'PARTNER' ? 'Travel partner' : 'Customer'}</div>
                </div>
            </div>
        </div>
    </aside>
    <div class="backdrop" data-nav-close></div>
    <div class="main">
        <header class="topbar">
            <button type="button" class="menu-btn" data-nav-toggle aria-label="Open menu" aria-controls="sidebar" aria-expanded="false">
                <svg class="i"><use href="${ico}#menu"/></svg>
            </button>
            <a class="brand" href="${ctx}/${sessionScope.user.role == 'PARTNER' ? 'partner' : 'customer'}/dashboard">
                <span class="brand-mark"><svg class="i"><use href="${ico}#route"/></svg></span>
                <span>EMPTY<b>MILES</b></span>
            </a>
        </header>
        <main class="content">
</c:when>
<c:otherwise>
<div class="plain-shell">
    <main class="content">
        <a class="brand" href="${ctx}/login">
            <span class="brand-mark"><svg class="i"><use href="${ico}#route"/></svg></span>
            <span>EMPTY<b>MILES</b></span>
        </a>
</c:otherwise>
</c:choose>
    <c:if test="${not empty sessionScope.flash}">
        <div class="alert alert-success" role="status">
            <svg class="i"><use href="${ico}#check-circle"/></svg>
            <span><c:out value="${sessionScope.flash}"/></span>
            <button type="button" class="alert-close" data-dismiss aria-label="Dismiss"><svg class="i i-sm"><use href="${ico}#x"/></svg></button>
        </div>
        <c:remove var="flash" scope="session"/>
    </c:if>
    <%-- flashError is read by pages that show it inline (e.g. the OTP card); otherwise it appears here --%>
    <c:if test="${not empty sessionScope.flashError and param.inlineErrors != 'true'}">
        <div class="alert alert-error" role="alert">
            <svg class="i"><use href="${ico}#alert"/></svg>
            <span><c:out value="${sessionScope.flashError}"/></span>
        </div>
        <c:remove var="flashError" scope="session"/>
    </c:if>
    <c:if test="${not empty requestScope.error and param.inlineErrors != 'true'}">
        <div class="alert alert-error" role="alert">
            <svg class="i"><use href="${ico}#alert"/></svg>
            <span><c:out value="${requestScope.error}"/></span>
        </div>
    </c:if>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="code" value="${requestScope['jakarta.servlet.error.status_code']}"/>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="${code == 404 ? 'Page not found' : (code == 403 ? 'Access denied' : 'Something went wrong')}"/>
    <jsp:param name="inlineErrors" value="true"/>
</jsp:include>
<%-- Friendly page for our own errors (requestScope.error) and container errors (403, 404, 500). --%>
<c:set var="home" value="${sessionScope.user.role == 'PARTNER' ? '/partner/dashboard' : (sessionScope.user.role == 'CUSTOMER' ? '/customer/dashboard' : '/login')}"/>
<div class="card" style="max-width:560px;margin:40px auto 0">
    <div class="empty">
        <c:choose>
            <c:when test="${code == 403}">
                <div class="empty-icon danger"><svg class="i"><use href="${ico}#lock"/></svg></div>
                <h2>You don't have permission to access this page.</h2>
                <p>This page belongs to a different account type. Head back to your dashboard to continue.</p>
            </c:when>
            <c:when test="${code == 404}">
                <div class="empty-icon warn"><svg class="i"><use href="${ico}#search"/></svg></div>
                <h2>Page not found</h2>
                <p>The page you asked for doesn't exist or has moved.</p>
            </c:when>
            <c:when test="${not empty requestScope.error}">
                <div class="empty-icon warn"><svg class="i"><use href="${ico}#alert"/></svg></div>
                <h2>We couldn't complete that</h2>
                <p><c:out value="${requestScope.error}"/></p>
            </c:when>
            <c:otherwise>
                <div class="empty-icon danger"><svg class="i"><use href="${ico}#alert"/></svg></div>
                <h2>Something went wrong</h2>
                <p>An unexpected error happened on our side. Please try again in a moment.</p>
            </c:otherwise>
        </c:choose>
        <div class="button-row" style="justify-content:center;margin-top:10px">
            <c:if test="${code != 403 and code != 404}">
                <button type="button" class="btn btn-outline" onclick="history.back()"><svg class="i"><use href="${ico}#refresh"/></svg><span>Try again</span></button>
            </c:if>
            <a class="btn btn-primary" href="${ctx}${home}"><span>${empty sessionScope.user ? 'Go to login' : 'Back to dashboard'}</span></a>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>

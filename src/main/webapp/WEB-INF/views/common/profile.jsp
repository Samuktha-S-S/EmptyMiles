<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Profile"/>
    <jsp:param name="nav" value="profile"/>
</jsp:include>
<c:set var="u" value="${sessionScope.user}"/>

<div class="page-head">
    <div>
        <h1>Profile</h1>
        <p>Your account details.</p>
    </div>
</div>

<div class="grid-main-side">
    <div class="stack">
        <section class="card">
            <div class="profile-head">
                <span class="avatar avatar-lg"><c:out value="${u.name.substring(0, 1)}"/></span>
                <div>
                    <h2><c:out value="${u.name}"/></h2>
                    <span class="badge ${u.partner ? 'tone-transit' : 'tone-confirmed'}" style="margin-top:6px">${u.partner ? 'Travel partner' : 'Customer'}</span>
                </div>
            </div>
            <dl class="kv" style="margin-top:24px">
                <dt>Name</dt><dd><c:out value="${u.name}"/></dd>
                <dt>Email</dt><dd><c:out value="${u.email}"/></dd>
                <c:if test="${not empty u.phone}"><dt>Phone</dt><dd><c:out value="${u.phone}"/></dd></c:if>
                <dt>Role</dt><dd>${u.partner ? 'Travel partner' : 'Customer'}</dd>
                <c:if test="${not empty u.createdAt}"><dt>Member since</dt><dd>${u.createdAt.format(df)}</dd></c:if>
            </dl>
        </section>

        <c:if test="${u.partner}">
            <section class="card">
                <div class="card-head">
                    <h2>Vehicle information</h2>
                    <a class="push-right btn btn-sm btn-ghost" href="${ctx}/partner/vehicles"><span>Manage</span><svg class="i"><use href="${ico}#chevron-right"/></svg></a>
                </div>
                <c:choose>
                    <c:when test="${empty vehicles}">
                        <div class="empty empty-compact">
                            <div class="empty-icon"><svg class="i"><use href="${ico}#truck"/></svg></div>
                            <h3>No vehicle yet</h3>
                            <a class="btn btn-primary" href="${ctx}/partner/vehicles#add"><svg class="i"><use href="${ico}#plus"/></svg><span>Add vehicle</span></a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="v" items="${vehicles}">
                            <%@ include file="../partner/vehicle-overview.jspf" %>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:if>
    </div>

    <section class="card">
        <div class="card-head"><h2>Account</h2></div>
        <p class="muted small">Your details are used to contact you about bookings. Phone numbers are shared only between a customer and the partner on the same booking.</p>
        <div class="button-row" style="margin-top:16px">
            <a class="btn btn-outline btn-block" href="${ctx}/help"><svg class="i"><use href="${ico}#help"/></svg><span>Help &amp; how it works</span></a>
            <a class="btn btn-danger btn-block" href="${ctx}/logout"><svg class="i"><use href="${ico}#logout"/></svg><span>Log out</span></a>
        </div>
    </section>
</div>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateFormatPattern" value="dd/MM/yyyy"/>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy HH:mm:ss"/>
<c:set var="shortDateFormatPattern" value="MMMM yyyy"/>
<tags:page title="${project.title}">
    <jsp:attribute name="head">
        <link rel="stylesheet" href="<c:url value="/js/openlayers/theme/default/style.css"/>" type="text/css">
        <link rel="stylesheet" href="<c:url value="/js/openlayers/theme/default/google.css"/>" type="text/css">
        <style type="text/css">
            #coverageMap {
                float: right;
                width: 240px;
                height: 200px;
            }
            #projectData {
                float:left;
                width:420px;
            }
            #projectDetails {
                float: left;
            }
            #content.narrow #projectDetails {
                width: 100%;
            }
            #content.wide #projectDetails {
                width: 690px;
            }
        </style>
        <script src="http://maps.google.com/maps/api/js?v=3.9&sensor=false"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/openlayers/OpenLayers.js"></script>
        <script type="text/javascript" src="<c:url value="/js/coverage.js"/>"></script>
        <script type="text/javascript"> 
            $(document).ready(function() {
                $('#navTrack').addClass('active');
                <c:if test="${not empty project.boundingBox}">
                var coverageMap = createCoverageMap('coverageMap', '<c:out value="${project.boundingBox}"/>');
                </c:if>
            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="<c:url value="/"/>">Home</a>
        &rsaquo; <a href="<c:url value="/projects"/>">Animal Tracking</a>
        &rsaquo; <span class="active">${project.title}</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <sec:authorize access="#project.global or hasPermission(#project, 'read')">
        <tags:project-menu project="${project}"/>
        </sec:authorize>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        
        <c:if test="${not empty project.boundingBox}">
        <div id="coverageMap"></div>
        </c:if>
        
        <sec:authorize access="#project.global or hasPermission(#project, 'read')">
        <div id="projectData">
        <h2 style="margin-top: 0;">Data Summary</h2>
        <c:choose>
        <c:when test="${(empty dataFileList)}">
             <p>
                 There is no data uploaded for this project yet.
                 <sec:authorize access="hasPermission(#project, 'write')">
                 You might like to <a href="<c:url value='/projects/${project.id}/datafiles/new'/>">upload a datafile</a>.
                 </sec:authorize>
             </p>
        </c:when>
        <c:otherwise>              
            <table class="entityTable">
            <col style="width: 120px;" />
            <sec:authorize access="hasPermission(#project, 'write')">
            <tr>
                <th>Datafile Count:</th>
                <td><a href="<c:url value="/projects/${project.id}/datafiles"/>"><c:out value="${fn:length(dataFileList)}"/></a></td>
            </tr>
            </sec:authorize>
            <tr>
                <th>Date Range:</th>
                <td><fmt:formatDate pattern="${dateFormatPattern}" value="${project.firstDetectionDate}"/> to <fmt:formatDate pattern="${dateFormatPattern}" value="${project.lastDetectionDate}"/></td>
            </tr>
            <tr>
                <th>Detection Count:</th>
                <td><a href="<c:url value="/projects/${project.id}/search"/>"><c:out value="${project.detectionCount}"/></a></td>
            </tr>
            <tr>
                <th>Animals:</th>
                <td>
                    <c:forEach items="${projectAnimalsList}" var="animal">
                    <a href="<c:url value="/animals/${animal.id}"/>"><c:out value="${animal.animalName}"/></a>,
                    </c:forEach>
                    <a href="<c:url value="/projects/${project.id}/animals"/>">View All</a>    
                </td>
            </tr>
            </table>
        </c:otherwise>
        </c:choose>
        </div>
        </sec:authorize>
        
        <div id="projectDetails">
        <h2 style="margin-top: 0;">Project Details</h2>
        <table class="entityTable">
        <col style="width: 120px;" />
        <tr>
            <th>Title:</th>
            <td><c:out value="${project.title}"/></td>
        </tr>
        <tr>
            <th>Description:</th>
            <td><c:out value="${project.description}"/></td>
        </tr>
        <tr>
            <th>Project Type:</th>
            <td><c:out value="${project.projectType.displayName}"/></td>
        </tr>
        <tr>
            <th>Species:</th>
            <td>
                <c:out value="${project.speciesCommonName}"/>
                <c:if test="${!empty project.speciesScientificName}"><i><br><c:out value="${project.speciesScientificName}"/></i></c:if>
          </td>
        </tr>
        <tr>
            <th>Temporal Coverage:</th>
            <td>
                <c:choose>
                <c:when test="${empty project.firstDetectionDate}">
                    No data has been uploaded for this project yet.
                </c:when>
                <c:otherwise>
                    <fmt:formatDate pattern="${shortDateFormatPattern}" value="${project.firstDetectionDate}"/> to <fmt:formatDate pattern="${shortDateFormatPattern}" value="${project.lastDetectionDate}"/>
                </c:otherwise>
                </c:choose>
            </td>
        </tr>
        <tr>
            <th>Spatial Coverage:</th>
            <td><c:out value="${project.spatialCoverageDescr}"/></td>
        </tr>
        <tr>
            <th>Contact:</th>
            <td>
                <c:out value="${project.dataSpaceAgent.firstName}"/>&nbsp;<c:out value="${project.dataSpaceAgent.lastName}"/><br>
                <a href="mailto:<c:out value="${project.dataSpaceAgent.email}"/>"><c:out value="${project.dataSpaceAgent.email}"/></a>
            </td>
        </tr>
        <tr>
            <th>Organisation:</th>
            <td><c:out value="${project.dataSpaceAgent.organisation}"/></td>
        </tr>
        <c:if test="${not empty project.publicationTitle}">
        <tr>
            <th>Publication:</th>
            <td>
                <i><c:out value="${project.publicationTitle}"/></i>
                <c:if test="${not empty project.publicationUrl}">
                <br>
                <a href="<c:out value="${project.publicationUrl}"/>"><c:out value="${project.publicationUrl}"/></a>
                </c:if>
            </td>
        </tr>
        </c:if>
        <tr>
            <th>Rights Statement:</th>
            <td><c:out value="${project.rightsStatement}"/></td>
        </tr>
        <tr>
            <th>Access Rights:</th>
            <td>
            <c:choose>
            <c:when test="${project.isGlobal}">
                The data in the project is available in OzTrack for the public to use.
            </c:when>
            <c:otherwise>
                The data in this project is only available to users on the OzTrack system whom have been granted access.
            </c:otherwise>
            </c:choose>
            </td>
        </tr>
        
        
        <sec:authorize access="hasPermission(#project, 'manage')">
        <tr>
            <th>Publication Status:</th>
            <td>
                <c:choose>
                <c:when test ="${empty project.dataSpaceUpdateDate}">
                    This project metadata has not yet been published externally.
                    <c:set var="publishButtonText" value="Publish Metadata to UQ DataSpace"/> 
                </c:when>
                <c:otherwise>
                    This project metadata has been published and was last updated on 
                    <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${project.dataSpaceUpdateDate}"/>.
                    <c:set var="publishButtonText" value="Update UQ DataSpace Collection Registry"/> 
                </c:otherwise>
                </c:choose>
            </td>
        </tr>
        </sec:authorize>
        
        </table>
        </div>
        
        <div style="clear: both;"></div>
        
        <sec:authorize access="hasPermission(#project, 'manage')">
        <h2>User Roles</h2>
        <table class="entityTable" style="width: 100%;">
        <col style="width: 33%;" />
        <col style="width: 33%;" />
        <col style="width: 33%;" />
        <tr>
            <th style="border-bottom: 1px solid #e6e6c0; ">Managers</th>
            <th style="border-bottom: 1px solid #e6e6c0;">Writers</th>
            <th style="border-bottom: 1px solid #e6e6c0;">Readers</th>
        </tr>
        <tr>
            <td>
                <tags:project-user-list projectUsers="${managerProjectUsers}" role="manager"/>
            </td>
            <td>
                <tags:project-user-list projectUsers="${writerProjectUsers}" role="writer"/>
            </td>
            <td>
                <tags:project-user-list projectUsers="${readerProjectUsers}" role="reader"/>
            </td>
        </tr>
        </table>
        </sec:authorize>
        
        <sec:authorize access="hasPermission(#project, 'write')">
        <div class="actions">
        <h2>Manage Project</h2>
        <ul>
            <li class="edit"><a href="<c:url value="/projects/${project.id}/edit"/>">Edit project</a></li>
            <sec:authorize access="hasPermission(#project, 'manage')">
            <c:if test="${empty project.dataSpaceURI}">
            <li class="delete"><a href="javascript:void(deleteEntity('<c:url value="/projects/${project.id}"/>', '<c:url value="/projects"/>', 'Are you sure you want to delete this project?'));">Delete project</a></li>
            </c:if>
            <li class="publish"><a href="<c:url value="/projects/${project.id}/publish"/>"><c:out value="${publishButtonText}"/></a></li>
            </sec:authorize>
        </ul>
        </div>
        </sec:authorize>
    </jsp:body>
</tags:page>

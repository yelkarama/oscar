/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */

package org.oscarehr.casemgmt.dao;


import org.oscarehr.casemgmt.model.CaseManagementDxLink;
import org.oscarehr.common.dao.AbstractDao;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
public class CaseManagementDxLinkDao extends AbstractDao<CaseManagementDxLink> {
    
    public CaseManagementDxLinkDao() {
        super(CaseManagementDxLink.class);
    }
    
    public List<CaseManagementDxLink> findByNoteId(Long noteId) {
        String sqlCommand="select x from " + modelClass.getSimpleName() + " x where x.id.noteId=?1";
        Query query = entityManager.createQuery(sqlCommand);
        query.setParameter(1, noteId);
        @SuppressWarnings("unchecked")
        List<CaseManagementDxLink> results = query.getResultList();
        return(results);
    }
    
    public List<CaseManagementDxLink> findByDemographicNoAndCoMorbidDx(Integer demographicNo, String coMorbidDxType, String coMorbidDxCode) {
        String sqlCommand = "SELECT dxl.* FROM casemgmt_dx_link dxl " + 
                        "LEFT JOIN  casemgmt_note cmn1 ON dxl.note_id = cmn1.note_id " + 
                        "INNER JOIN (" + 
                            "SELECT MAX(note_id) max_note_id, uuid FROM casemgmt_note " + 
                            "WHERE demographic_no = :demographicNo " + 
                            "GROUP BY uuid) cmn2 " + 
                        "ON cmn1.note_id = cmn2.max_note_id AND cmn1.uuid = cmn2.uuid " + 
                        "WHERE cmn1.archived = 0 " + 
                        "AND dxl.co_morbid_dx_type = :coMorbidDxType " + 
                        "AND dxl.co_morbid_dx_code = :coMorbidDxCode";
        Query query = entityManager.createNativeQuery(sqlCommand, modelClass);
        query.setParameter("demographicNo", demographicNo);
        query.setParameter("coMorbidDxType", coMorbidDxType);
        query.setParameter("coMorbidDxCode", coMorbidDxCode);
        @SuppressWarnings("unchecked")
        List<CaseManagementDxLink> results = query.getResultList();
        return(results);
    }
}
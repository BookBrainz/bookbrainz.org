/*
 * Copyright (C) 2016  Ben Ockmore
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import React from 'react';
import PropTypes from 'prop-types';
import {connect} from 'react-redux';
import {Button, OverlayTrigger, Tooltip} from 'react-bootstrap';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import {faQuestionCircle} from '@fortawesome/free-solid-svg-icons';
import IdentifierModalBody from './identifier-modal-body';
import {removeEmptyIdentifiers} from './actions';

/**
 * Container component. The IdentifierEditor component contains a number of
 * IdentifierRow elements, and renders these inside a modal, which appears when
 * the show property of the component is set.
 *
 * @param {Object} props - The properties passed to the component.
 * @param {Array} props.identifiers - The list of identifiers to be rendered in
 *        the editor.
 * @param {Array} props.identifierTypes - The list of possible types for an
 *        identifier.
 * @param {Function} props.onAddIdentifier - A function to be called when the
 *        button to add an identifier is clicked.
 * @param {Function} props.onClose - A function to be called when the button to
 *        add the identifier is clicked.
 * @returns {ReactElement} React element containing the rendered
 *          IdentifierEditor.
 */
const IdentifierEditor = ({
	identifierTypes,
	onClose
}) => {
	const helpText = `identity of the entity in other databases and services, such as ISBN, barcode, MusicBrainz ID, WikiData ID, OpenLibrary ID, etc.
	You can enter either the identifier only (Q2517049) or a full link (https://www.wikidata.org/wiki/Q2517049).`;

	const helpIconElement = (
		<OverlayTrigger
			delay={50}
			overlay={<Tooltip id="identifier-editor-tooltip">{helpText}</Tooltip>}
			placement="right"
		>
			<FontAwesomeIcon
				className="fa-sm"
				icon={faQuestionCircle}
			/>
		</OverlayTrigger>
	);

	return (
		<div>
			<div>
				<div style={{display: 'flex'}}>
					<h2>Add new indentifiers</h2>
					<div>
						{helpIconElement}
					</div>
				</div>
			</div>

			<div>
				<IdentifierModalBody identifierTypes={identifierTypes}/>
			</div>

			<div>
				<Button variant="primary" onClick={onClose}>Done</Button>
			</div>
		</div>
	);
};
IdentifierEditor.displayName = 'IdentifierEditor';
IdentifierEditor.propTypes = {
	identifierTypes: PropTypes.array.isRequired,
	onClose: PropTypes.func.isRequired
};
function mapDispatchToProps(dispatch) {
	return {
		onClose: () => {
			dispatch(removeEmptyIdentifiers());
		}
	};
}

export default connect(null, mapDispatchToProps)(IdentifierEditor);

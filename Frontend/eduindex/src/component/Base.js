import React, { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import MetaMaskOnboarding from '@metamask/onboarding';
import { qGetProfile,gGetProfileMetadata } from '../script/queries';
import { request } from 'graphql-request'

const ONBOARD_TEXT = 'Click here to install MetaMask!';
const CONNECT_TEXT = 'Connect';
const CONNECTED_TEXT = 'Connected';


function Base() {

  const [buttonText, setButtonText] = useState(ONBOARD_TEXT);
  const [isDisabled, setDisabled] = useState(false);
  const [accounts, setAccounts] = useState([]);
  const [profileBtnText, setProfileBtnText] = useState('Create Profile')
  const [profileLink, setProfileLink] = useState('/createprofile')
  const [profileId, setProfileId] = useState(0)
  const onboarding = useRef();


  useEffect(() => {
    if (!onboarding.current) {
      onboarding.current = new MetaMaskOnboarding();
    }
  }, []);

  useEffect(() => {
    if (MetaMaskOnboarding.isMetaMaskInstalled()) {
      if (accounts.length > 0) {
        setButtonText(CONNECTED_TEXT);
        setDisabled(true);
        onboarding.current.stopOnboarding();
        getProfile()
      } else {
        setButtonText(CONNECT_TEXT);
        setDisabled(false);
      }
    }
  }, [accounts]);

  useEffect(() => {
    handleaccounts()
  }, []);

  const handleaccounts = async () => {
    function handleNewAccounts(newAccounts) {
      setAccounts(newAccounts);
    }
    if (MetaMaskOnboarding.isMetaMaskInstalled()) {
      await window.ethereum
        .request({ method: 'eth_requestAccounts' })
        .then(handleNewAccounts);
      await window.ethereum.on('accountsChanged', handleNewAccounts);
      return async () => {
        await window.ethereum.off('accountsChanged', handleNewAccounts);
      };
    }
  }

  const getProfile = async () => {
    const queryParameters = {
      "to": accounts[0].toString()
    }
    const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
    if (response.profileCreateds.length > 0) {
      const metadata = await request(process.env.REACT_APP_GRAPH_URL, gGetProfileMetadata, {"profileId":response.profileCreateds[0].profileId})
      if(metadata.profileMetadataSets.length === 0) {
        setProfileBtnText('Update Profile')
        setProfileLink('/createprofile')
      } else {
        setProfileBtnText('View Profile')
        setProfileLink('/viewprofile')
      }
      
      setProfileId(response.profileCreateds[0].profileId)
    } else {
      setProfileBtnText('Create Profile')
      setProfileLink('/createprofile')
      setProfileId(0)
    }
    //console.log(response)
  }

  const onClick = async () => {
    if (MetaMaskOnboarding.isMetaMaskInstalled()) {
      await window.ethereum
        .request({ method: 'eth_requestAccounts' })
        .then((newAccounts) => setAccounts(newAccounts));
    } else {
      onboarding.current.startOnboarding();
    }
  };
  return (
    <nav className="navbar navbar-expand-lg bg-body-tertiary sticky-top border-bottom border-secondary" >
      <div className="container-fluid">
        <Link className="navbar-brand " to="/">EDUIndex</Link>
        <button className="navbar-toggler " type="button" data-bs-toggle="collapse" data-bs-target="#navbarToggler" aria-controls="navbarToggler" aria-expanded="false" aria-label="Toggle navigation">
          <i className="bi bi-list "></i>
        </button>
        <div className="collapse navbar-collapse" id="navbarToggler">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0">
            <li className="nav-item">
              <Link className="nav-link active " aria-current="page" to='/coursecatalog'>Course Catalog</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link active " aria-current="page" to='/mycourse'>MyCourse</Link>
            </li>
            {/* <li className="nav-item">
                <Link className="nav-link active " aria-current="page" to='/application'>Application</Link>
              </li> */}
          </ul>
          <span className="text-danger me-2 mb-3" hidden={profileId !== 0}> Please create a profile first!</span>
          <div className='d-flex'>
            <Link to={profileLink} className="btn btn-CourseCatalog form-control mb-3 me-3">{profileBtnText}</Link>
            <button
              className="btn btn-outline-dark mb-3 "
              disabled={isDisabled} onClick={onClick} style={{ border: 'round' }}
            >
              {buttonText}
            </button>
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Base
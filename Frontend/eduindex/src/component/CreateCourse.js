import React, { useState, useEffect, createRef } from 'react';
import '../css/CreateCourse.css'
import MetaMaskOnboarding from '@metamask/onboarding';
import { create } from 'ipfs-http-client'
import EduxHub from '../script/EduxHub'
import web3 from '../script/web3_'
import { Buffer } from 'buffer';
import { qGetProfile } from '../script/queries';
import { request } from 'graphql-request'

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;
const auth = 'Basic ' + Buffer.from(projectId + ':' + projectSecret).toString('base64');
const ipfsClient = create({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
    headers: {
        authorization: auth,
    },
})

function CreateCourse() {
    const [errorMessage, setErrorMessage] = useState('')
    const [loading, setLoading] = useState(true)
    const [accounts, setAccounts] = useState('')
    const [coursename, setCoursename] = useState('')
    const [coursedesc, setCoursedesc] = useState('')
    const [authordesc, setAuthordesc] = useState('')
    const [collectModule, setCollectModule] = useState('')
    const [NFTCertificateModule, setNFTCertificateModule] = useState('')
    const [recipientAddress, setRecipientAddress] = useState('')
    const [courseFee, setCourseFee] = useState('')
    const [profileId, setProfileId] = useState(0)

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

    useEffect(() => {
        if (accounts.length > 0) {
            getProfile()
            let collectModuleInitData = web3.eth.abi.encodeParameters(["uint160", "uint96", "address", "uint72", "address"], ["5000000000000000000", "0", "0x4776699A38Cd0ab16A3Ea18CB2ffbcE43aa99E6C", "0", "0xbbf3e9E8872009B26E9d8cF16577fe234AeC899c"]);
            ////console.log(collectModuleInitData)
        }

    }, [accounts])

    const getProfile = async () => {
        const queryParameters = {
            "to": accounts[0].toString()
        }
        const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
        if (response.profileCreateds.length > 0) {
            setProfileId(response.profileCreateds[0].profileId)
            return response.profileCreateds[0].profileId
            // //console.log(result)
        } else {
            setProfileId(0)
            return 0
        }
    }

    async function uploadData() {

        try {
            const metaDataPath = await ipfsClient.add(JSON.stringify({
                courseName: coursename,
                courseDesc: coursedesc,
                authorDesc: authordesc,
                courseFee: web3.utils.toWei(courseFee, 'ether')
            }))
            //console.log(metaDataPath)
            await ipfsClient.pin.add(metaDataPath.path.toString())
            return metaDataPath.path.toString()

        } catch (err) {
            //console.log(err)
            setErrorMessage("Opps! Somthing went wrong.")
            return 'error'
        }

    }

    const onSubmitCreateCourse = async (event) => {
        setErrorMessage('')
        event.preventDefault()
        setLoading(false)
        try {
            setErrorMessage('Uploading Course data to IPFS...')
            const CID = await uploadData()
            if (CID !== 'error') {
                setErrorMessage('Uploaded Course data to IPFS.')
                //console.log(CID)
                let courseFeewei = web3.utils.toWei(courseFee, 'ether')
                let collectModuleInitData = web3.eth.abi.encodeParameters(["uint160", "uint96", "address", "uint72", "address"], [courseFeewei, "0", process.env.REACT_APP_WEDU_ADDRESS, "0", recipientAddress]);
                let receipt = await EduxHub.methods.course([profileId, CID, NFTCertificateModule, collectModule, collectModuleInitData]).send({
                    from: accounts[0]
                })
                //console.log(receipt)
                setErrorMessage("Course created successfully")

            }
            setLoading(true)
            window.location.replace('/coursecatalog')

        } catch (error) {
            //console.log(error)
            setErrorMessage(error.message)
            setLoading(true)
        }

    }

    return (
        <div className='container-fluid'>
            <div className='row d-flex justify-content-center align-items-center'>
                <div className='CreateCourseContainer'>
                    <h3 className="card-title m-2 text-center">Course Portal</h3>
                    <div className="container card shadow rounded-2">
                        <div className="accordion accordion-flush mt-2" id="createFlush">
                            <div className="accordion-item">
                                <h2 className="accordion-header" id="create-heading">
                                    <button className='accordion-button fw-bold rounded-2' type="button" data-bs-toggle="collapse" data-bs-target="#create-collapse" aria-expanded="true" aria-controls="create-collapse">
                                        Create Course
                                    </button>
                                </h2>
                                <div id="create-collapse" className='accordion-collapse collapse show' aria-labelledby="create-heading" data-bs-parent="#createFlush">
                                    <div className="accordion-body">
                                        <form onSubmit={onSubmitCreateCourse}>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Creator ProfileId</label>
                                                <div className="col-sm-10">
                                                    <input type='text'
                                                        className="form-control" style={{ background: "#e9ecef" }}
                                                        value={profileId}
                                                        required
                                                        readOnly
                                                    />
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Name</label>
                                                <div className="col-sm-10">
                                                    <input type="text" className='form-control'
                                                        value={coursename}
                                                        onChange={(event) => setCoursename(event.target.value)}
                                                        required
                                                    />
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Description</label>
                                                <div className="col-sm-10">
                                                    <textarea className="form-control" rows="3"
                                                        value={coursedesc}
                                                        onChange={(event) => setCoursedesc(event.target.value)}
                                                        required
                                                    ></textarea>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Author Description</label>
                                                <div className="col-sm-10">
                                                    <textarea className="form-control" rows="3"
                                                        value={authordesc}
                                                        onChange={(event) => setAuthordesc(event.target.value)}
                                                        required
                                                    ></textarea>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">NFT Certificate Module</label>
                                                <div className="col-sm-10">
                                                    <select className="form-select" aria-label="Default select example" required
                                                        onChange={(event) => setNFTCertificateModule(event.target.value)}>
                                                        <option value=""></option>
                                                        <option value="0xd30fb36Db7D3E85D2A57E69B1e90b311A94A6716">BaseNFTCertificateModule</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Collect Module</label>
                                                <div className="col-sm-10">
                                                    <select className="form-select" aria-label="Default select example" required
                                                        onChange={(event) => setCollectModule(event.target.value)}>
                                                        <option value=""></option>
                                                        <option value="0xb6FfaeFc397e9739385e464954434aD39f534332">SimpleFeeCollectModule</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div className="mb-3 row align-items-center">
                                                <label className="col-sm-2 col-form-label">Course Fee</label>
                                                <div className="col-sm-2">
                                                    <input type="number" className="form-control"
                                                        value={courseFee}
                                                        onChange={(event) => setCourseFee(event.target.value)}
                                                        required />
                                                </div>
                                                <div className='col-sm-3'>
                                                    <span className='fw-light'> WEDU</span>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Fee Recipient Address</label>
                                                <div className="col-sm-10">
                                                    <input className="form-control"
                                                        value={recipientAddress}
                                                        onChange={(event) => setRecipientAddress(event.target.value)}
                                                        required
                                                    />
                                                </div>
                                            </div>
                                            <span className="text-danger" hidden={!errorMessage}>{errorMessage}</span>
                                            <div className="mb-3 d-flex" style={{ alignItems: 'center' }}>
                                                <button type="submit" className="btn btn-CourseCatalog form-control" disabled={(!loading) || profileId === 0}>
                                                    <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={loading}></span>
                                                    Create Course</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}


export default CreateCourse